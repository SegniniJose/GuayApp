package main

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// Helper: Genera IDs aleatorios similares a UUID
func generateID() string {
	b := make([]byte, 16)
	rand.Read(b)
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
}

// Helper: Genera códigos únicos para unirse a ligas (6 caracteres alfanuméricos)
func generateLeagueCode() string {
	const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, 6)
	for i := range b {
		n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(letters))))
		b[i] = letters[n.Int64()]
	}
	return string(b)
}

// CORS Middleware para permitir comunicaciones de orígenes cruzados (local y GitHub Pages)
func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

// ==========================================
// 1. CONTROLADORES DE AUTENTICACIÓN
// ==========================================

func handleRegister(c *gin.Context) {
	var req struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Datos de registro inválidos"})
		return
	}

	var existing User
	if err := DB.Where("username = ? OR email = ?", req.Username, req.Email).First(&existing).Error; err == nil {
		c.JSON(400, gin.H{"error": "El nombre de usuario o email ya existe"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(500, gin.H{"error": "Error interno al procesar contraseña"})
		return
	}

	user := User{
		ID:        generateID(),
		Username:  req.Username,
		Email:     req.Email,
		Password:  string(hashedPassword),
		Avatar:    "https://api.dicebear.com/7.x/adventurer/svg?seed=" + req.Username,
		Points:    0,
		IsPrivate: true,
	}

	if err := DB.Create(&user).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al guardar el usuario"})
		return
	}

	c.JSON(200, user)
}

func handleLogin(c *gin.Context) {
	var req struct {
		Identifier string `json:"identifier"`
		Password   string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Datos de inicio de sesión inválidos"})
		return
	}

	var user User
	if err := DB.Where("username = ? OR email = ?", req.Identifier, req.Identifier).First(&user).Error; err != nil {
		c.JSON(401, gin.H{"error": "Usuario o contraseña inválidos"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(401, gin.H{"error": "Usuario o contraseña inválidos"})
		return
	}

	c.JSON(200, user)
}

// ==========================================
// 2. CONTROLADORES DE USUARIOS
// ==========================================

func handleGetProfile(c *gin.Context) {
	userId := c.Param("userId")
	var user User
	if err := DB.First(&user, "id = ?", userId).Error; err != nil {
		c.JSON(404, gin.H{"error": "Usuario no encontrado"})
		return
	}
	c.JSON(200, user)
}

func handleGetPhotoCount(c *gin.Context) {
	userId := c.Param("userId")
	var count int64
	DB.Model(&MissionCompletion{}).Where("user_id = ? AND status = ?", userId, "validated").Count(&count)
	c.JSON(200, gin.H{"count": count})
}

func handleGetSuggestions(c *gin.Context) {
	userId := c.Param("userId")
	limitStr := c.DefaultQuery("limit", "5")
	limit := 5
	fmt.Sscanf(limitStr, "%d", &limit)

	var friendIds []string
	DB.Model(&Friendship{}).Where("user_id = ?", userId).Pluck("friend_id", &friendIds)
	var friendIds2 []string
	DB.Model(&Friendship{}).Where("friend_id = ?", userId).Pluck("user_id", &friendIds2)

	friendIds = append(friendIds, friendIds2...)
	friendIds = append(friendIds, userId) // Excluirse a sí mismo

	var suggestions []User
	DB.Where("id NOT IN ?", friendIds).Limit(limit).Find(&suggestions)
	c.JSON(200, suggestions)
}

func handleSearchUsers(c *gin.Context) {
	query := c.Query("query")
	userId := c.Query("userId")

	var users []User
	DB.Where("username LIKE ? AND id != ?", "%"+query+"%", userId).Find(&users)
	c.JSON(200, users)
}

// ==========================================
// 3. CONTROLADORES DE AMIGOS
// ==========================================

func handleFriendRequest(c *gin.Context) {
	var req struct {
		UserID   string `json:"userId"`
		FriendID string `json:"friendId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	var existing Friendship
	err := DB.Where("(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)", req.UserID, req.FriendID, req.FriendID, req.UserID).First(&existing).Error
	if err == nil {
		c.JSON(400, gin.H{"error": "Ya existe una solicitud o ya son amigos"})
		return
	}

	friendship := Friendship{
		ID:       generateID(),
		UserID:   req.UserID,
		FriendID: req.FriendID,
		Status:   "pending",
	}

	if err := DB.Create(&friendship).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al procesar la solicitud de amistad"})
		return
	}

	var sender User
	DB.First(&sender, "id = ?", req.UserID)

	notification := Notification{
		ID:          generateID(),
		UserID:      req.FriendID,
		SenderID:    req.UserID,
		Type:        "friend_request",
		ReferenceID: friendship.ID,
		Title:       "Solicitud de amistad",
		Content:     fmt.Sprintf("%s te ha enviado una solicitud de amistad.", sender.Username),
		IsRead:      false,
		CreatedAt:   time.Now().UnixNano() / int64(time.Millisecond),
	}
	DB.Create(&notification)

	c.JSON(200, friendship)
}

func handleFriendAccept(c *gin.Context) {
	var req struct {
		FriendID     string `json:"friendId"`
		FriendshipID string `json:"friendshipId"`
		UserID       string `json:"userId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	var friendship Friendship
	if err := DB.First(&friendship, "id = ?", req.FriendshipID).Error; err != nil {
		c.JSON(404, gin.H{"error": "Amistad no encontrada"})
		return
	}

	friendship.Status = "accepted"
	DB.Save(&friendship)

	// Marcar notificaciones correspondientes como leídas
	DB.Model(&Notification{}).Where("user_id = ? AND reference_id = ?", req.UserID, req.FriendshipID).Update("is_read", true)

	c.JSON(200, friendship)
}

func handleFriendReject(c *gin.Context) {
	var req struct {
		FriendshipID string `json:"friendshipId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	DB.Delete(&Friendship{}, "id = ?", req.FriendshipID)
	DB.Delete(&Notification{}, "reference_id = ?", req.FriendshipID)

	c.JSON(200, gin.H{"status": "success"})
}

func handleGetFriends(c *gin.Context) {
	userId := c.Param("userId")
	var friendships []Friendship
	DB.Where("status = ? AND (user_id = ? OR friend_id = ?)", "accepted", userId, userId).Find(&friendships)

	var friends []User
	for _, f := range friendships {
		friendId := f.FriendID
		if f.FriendID == userId {
			friendId = f.UserID
		}
		var u User
		if err := DB.First(&u, "id = ?", friendId).Error; err == nil {
			friends = append(friends, u)
		}
	}
	c.JSON(200, friends)
}

func handleGetPendingFriends(c *gin.Context) {
	userId := c.Param("userId")
	var friendships []Friendship
	DB.Where("friend_id = ? AND status = ?", userId, "pending").Find(&friendships)

	type InboundResponse struct {
		ID   string `json:"id"`
		User User   `json:"user"`
	}

	var response []InboundResponse
	for _, f := range friendships {
		var u User
		if err := DB.First(&u, "id = ?", f.UserID).Error; err == nil {
			response = append(response, InboundResponse{
				ID:   f.ID,
				User: u,
			})
		}
	}
	c.JSON(200, response)
}

func handleGetSentRequests(c *gin.Context) {
	userId := c.Param("userId")
	var friendships []Friendship
	DB.Where("user_id = ? AND status = ?", userId, "pending").Find(&friendships)

	type OutboundResponse struct {
		ID   string `json:"id"`
		User User   `json:"user"`
	}

	var response []OutboundResponse
	for _, f := range friendships {
		var u User
		if err := DB.First(&u, "id = ?", f.FriendID).Error; err == nil {
			response = append(response, OutboundResponse{
				ID:   f.ID,
				User: u,
			})
		}
	}
	c.JSON(200, response)
}

// ==========================================
// 4. CONTROLADORES DE LIGAS
// ==========================================

func handleCreateLeague(c *gin.Context) {
	var req struct {
		AdminID         string `json:"adminId"`
		IsPublic        bool   `json:"isPublic"`
		Name            string `json:"name"`
		DurationDays    *int   `json:"durationDays,omitempty"`
		DurationMinutes *int   `json:"durationMinutes,omitempty"`
		VenueName       string `json:"venueName,omitempty"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	league := League{
		ID:              generateID(),
		Name:            req.Name,
		Code:            generateLeagueCode(),
		AdminID:         req.AdminID,
		IsPublic:        req.IsPublic,
		DurationDays:    req.DurationDays,
		DurationMinutes: req.DurationMinutes,
		VenueName:       req.VenueName,
		Status:          "active",
	}

	if err := DB.Create(&league).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al crear la liga"})
		return
	}

	DB.Model(&User{}).Where("id = ?", req.AdminID).Update("league_id", league.ID)
	c.JSON(200, league)
}

func handleGetLeagueByCode(c *gin.Context) {
	code := c.Param("code")
	var league League
	if err := DB.First(&league, "code = ?", code).Error; err != nil {
		c.JSON(404, gin.H{"error": "Liga no encontrada"})
		return
	}
	c.JSON(200, league)
}

func handleGetLeagueByID(c *gin.Context) {
	leagueId := c.Param("leagueId")
	var league League
	if err := DB.First(&league, "id = ?", leagueId).Error; err != nil {
		c.JSON(404, gin.H{"error": "Liga no encontrada"})
		return
	}
	c.JSON(200, league)
}

func handleJoinLeague(c *gin.Context) {
	leagueId := c.Param("leagueId")
	var req struct {
		UserID string `json:"userId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	if err := DB.Model(&User{}).Where("id = ?", req.UserID).Update("league_id", leagueId).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al registrarse en la liga"})
		return
	}
	c.JSON(200, gin.H{"status": "success"})
}

func handleGetLeagueStatus(c *gin.Context) {
	leagueId := c.Param("leagueId")
	var league League
	if err := DB.First(&league, "id = ?", leagueId).Error; err != nil {
		c.JSON(404, gin.H{"error": "Liga no encontrada"})
		return
	}
	c.JSON(200, gin.H{"status": league.Status})
}

func handleGetLeagueMembers(c *gin.Context) {
	leagueId := c.Param("leagueId")
	var members []User
	DB.Where("league_id = ?", leagueId).Find(&members)
	c.JSON(200, members)
}

func handleGetPublicLeagues(c *gin.Context) {
	var leagues []League
	DB.Where("is_public = ? AND status = ?", true, "active").Find(&leagues)
	c.JSON(200, leagues)
}

// ==========================================
// 5. CONTROLADORES DE CHATS/MENSAJES
// ==========================================

func handleGetLeagueMessages(c *gin.Context) {
	leagueId := c.Param("leagueId")
	var messages []Message
	DB.Where("league_id = ?", leagueId).Order("timestamp asc").Find(&messages)

	type MessageResponse struct {
		Content   string `json:"content"`
		Timestamp int64  `json:"timestamp"`
		LeagueID  string `json:"leagueId"`
		UserID    string `json:"userId"`
		Avatar    string `json:"avatar"`
		Username  string `json:"username"`
	}

	var response []MessageResponse = []MessageResponse{}
	for _, msg := range messages {
		var u User
		DB.First(&u, "id = ?", msg.SenderID)
		response = append(response, MessageResponse{
			Content:   msg.Content,
			Timestamp: msg.Timestamp,
			LeagueID:  msg.LeagueID,
			UserID:    msg.SenderID,
			Avatar:    u.Avatar,
			Username:  u.Username,
		})
	}
	c.JSON(200, response)
}

func handleSendLeagueMessage(c *gin.Context) {
	var req struct {
		Content  string `json:"content"`
		LeagueID string `json:"leagueId"`
		UserID   string `json:"userId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	msg := Message{
		ID:        generateID(),
		LeagueID:  req.LeagueID,
		SenderID:  req.UserID,
		Content:   req.Content,
		Type:      "text",
		Timestamp: time.Now().UnixNano() / int64(time.Millisecond),
	}

	if err := DB.Create(&msg).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al procesar el mensaje"})
		return
	}
	c.JSON(200, msg)
}

func handleGetPrivateMessages(c *gin.Context) {
	userId := c.Param("userId")
	friendId := c.Param("friendId")

	var messages []Message
	DB.Where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)", userId, friendId, friendId, userId).Order("timestamp asc").Find(&messages)

	type PrivateResponse struct {
		Content      string `json:"content"`
		Timestamp    int64  `json:"timestamp"`
		SenderID     string `json:"senderId"`
		ReceiverID   string `json:"receiverId"`
		SenderAvatar string `json:"senderAvatar"`
	}

	var response []PrivateResponse = []PrivateResponse{}
	for _, msg := range messages {
		var u User
		DB.First(&u, "id = ?", msg.SenderID)
		response = append(response, PrivateResponse{
			Content:      msg.Content,
			Timestamp:    msg.Timestamp,
			SenderID:     msg.SenderID,
			ReceiverID:   msg.ReceiverID,
			SenderAvatar: u.Avatar,
		})
	}
	c.JSON(200, response)
}

func handleSendPrivateMessage(c *gin.Context) {
	var req struct {
		Content    string `json:"content"`
		ReceiverID string `json:"receiverId"`
		SenderID   string `json:"senderId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	msg := Message{
		ID:         generateID(),
		SenderID:   req.SenderID,
		ReceiverID: req.ReceiverID,
		Content:    req.Content,
		Type:       "text",
		Timestamp:  time.Now().UnixNano() / int64(time.Millisecond),
	}

	if err := DB.Create(&msg).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al procesar el mensaje"})
		return
	}

	var sender User
	DB.First(&sender, "id = ?", req.SenderID)

	notification := Notification{
		ID:          generateID(),
		UserID:      req.ReceiverID,
		SenderID:    req.SenderID,
		Type:        "private_message",
		ReferenceID: sender.ID,
		Title:       "Mensaje privado nuevo",
		Content:     fmt.Sprintf("%s te envió un mensaje privado.", sender.Username),
		IsRead:      false,
		CreatedAt:   time.Now().UnixNano() / int64(time.Millisecond),
	}
	DB.Create(&notification)

	c.JSON(200, msg)
}

func handleGetUnreadMessages(c *gin.Context) {
	c.JSON(200, []interface{}{})
}

// ==========================================
// 6. CONTROLADORES DE MISIONES Y HISTORIAS
// ==========================================

func handleGetMissions(c *gin.Context) {
	userId := c.Query("userId")
	var missions []Mission
	DB.Find(&missions)

	type MissionResponse struct {
		ID          string `json:"id"`
		Title       string `json:"title"`
		Description string `json:"description"`
		Points      int    `json:"points"`
		IsPending   bool   `json:"isPending"`
		Completed   bool   `json:"completed"`
	}

	var response []MissionResponse = []MissionResponse{}
	for _, m := range missions {
		var completion MissionCompletion
		isPending := false
		completed := false

		err := DB.Where("mission_id = ? AND user_id = ?", m.ID, userId).First(&completion).Error
		if err == nil {
			if completion.Status == "pending_validation" {
				isPending = true
			} else if completion.Status == "validated" {
				completed = true
			}
		}

		response = append(response, MissionResponse{
			ID:          m.ID,
			Title:       m.Title,
			Description: m.Description,
			Points:      m.Points,
			IsPending:   isPending,
			Completed:   completed,
		})
	}
	c.JSON(200, response)
}

func handleCompleteMission(c *gin.Context) {
	missionId := c.Param("missionId")
	var req struct {
		LeagueID string `json:"leagueId"`
		PhotoURL string `json:"photoUrl"`
		UserID   string `json:"userId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	var existing MissionCompletion
	err := DB.Where("mission_id = ? AND user_id = ? AND league_id = ?", missionId, req.UserID, req.LeagueID).First(&existing).Error
	if err == nil {
		c.JSON(400, gin.H{"error": "Ya has completado o subido esta foto para esta misión"})
		return
	}

	completion := MissionCompletion{
		ID:        generateID(),
		MissionID: missionId,
		LeagueID:  req.LeagueID,
		UserID:    req.UserID,
		PhotoURL:  req.PhotoURL,
		Status:    "pending_validation",
	}

	if err := DB.Create(&completion).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al registrar la misión"})
		return
	}

	var members []User
	DB.Where("league_id = ? AND id != ?", req.LeagueID, req.UserID).Find(&members)

	var uploader User
	DB.First(&uploader, "id = ?", req.UserID)

	var mission Mission
	DB.First(&mission, "id = ?", missionId)

	for _, member := range members {
		notification := Notification{
			ID:          generateID(),
			UserID:      member.ID,
			SenderID:    req.UserID,
			Type:        "validation",
			ReferenceID: completion.ID,
			Title:       "Nueva foto para validar",
			Content:     fmt.Sprintf("%s completó '%s'. ¡Valida su foto!", uploader.Username, mission.Description),
			IsRead:      false,
			CreatedAt:   time.Now().UnixNano() / int64(time.Millisecond),
		}
		DB.Create(&notification)
	}

	c.JSON(200, completion)
}

func handlePostVote(c *gin.Context) {
	var req struct {
		IsValid             string `json:"isValid"` // "true" o "false"
		MissionCompletionID string `json:"missionCompletionId"`
		UserID              string `json:"userId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Parámetros inválidos"})
		return
	}

	isValidBool := req.IsValid == "true"

	var existing Vote
	err := DB.Where("user_id = ? AND mission_completion_id = ?", req.UserID, req.MissionCompletionID).First(&existing).Error
	if err == nil {
		c.JSON(400, gin.H{"error": "Ya has votado por esta foto"})
		return
	}

	vote := Vote{
		ID:                  generateID(),
		UserID:              req.UserID,
		MissionCompletionID: req.MissionCompletionID,
		IsValid:             isValidBool,
	}

	if err := DB.Create(&vote).Error; err != nil {
		c.JSON(500, gin.H{"error": "Error al procesar el voto"})
		return
	}

	var completion MissionCompletion
	if err := DB.First(&completion, "id = ?", req.MissionCompletionID).Error; err == nil {
		if isValidBool {
			completion.Status = "validated"
			DB.Save(&completion)

			var mission Mission
			DB.First(&mission, "id = ?", completion.MissionID)

			var uploader User
			if err := DB.First(&uploader, "id = ?", completion.UserID).Error; err == nil {
				uploader.Points += mission.Points
				DB.Save(&uploader)
			}

			// Marcar la notificación como leída
			DB.Model(&Notification{}).Where("reference_id = ?", completion.ID).Update("is_read", true)
		} else {
			completion.Status = "rejected"
			DB.Save(&completion)
		}
	}

	c.JSON(200, vote)
}

func handleGetStories(c *gin.Context) {
	leagueId := c.Param("leagueId")
	userId := c.Query("userId")

	var members []User
	DB.Where("league_id = ?", leagueId).Find(&members)

	type StoryItem struct {
		MissionCompletionID string `json:"missionCompletionId"`
		MissionDescription  string `json:"missionDescription"`
		PhotoURL            string `json:"photoUrl"`
		MyVote              *bool  `json:"myVote"`
	}

	type UserAndStories struct {
		UserID   string      `json:"userId"`
		Username string      `json:"username"`
		Avatar   string      `json:"avatar"`
		Stories  []StoryItem `json:"stories"`
	}

	var response []UserAndStories = []UserAndStories{}

	for _, member := range members {
		var completions []MissionCompletion
		DB.Where("user_id = ? AND league_id = ?", member.ID, leagueId).Find(&completions)

		var stories []StoryItem = []StoryItem{}
		for _, comp := range completions {
			var mission Mission
			DB.First(&mission, "id = ?", comp.MissionID)

			var vote Vote
			var myVote *bool = nil
			err := DB.Where("user_id = ? AND mission_completion_id = ?", userId, comp.ID).First(&vote).Error
			if err == nil {
				val := vote.IsValid
				myVote = &val
			}

			if comp.Status == "pending_validation" || myVote != nil {
				stories = append(stories, StoryItem{
					MissionCompletionID: comp.ID,
					MissionDescription:  mission.Description,
					PhotoURL:            comp.PhotoURL,
					MyVote:              myVote,
				})
			}
		}

		if len(stories) > 0 {
			response = append(response, UserAndStories{
				UserID:   member.ID,
				Username: member.Username,
				Avatar:   member.Avatar,
				Stories:  stories,
			})
		}
	}

	c.JSON(200, response)
}

// ==========================================
// 7. CONTROLADORES DE NOTIFICACIONES
// ==========================================

func handleGetNotifications(c *gin.Context) {
	userId := c.Param("userId")
	var notifications []Notification
	DB.Where("user_id = ?", userId).Order("created_at desc").Find(&notifications)

	type NotificationResponse struct {
		ID           string `json:"id"`
		Type         string `json:"type"`
		SenderID     string `json:"senderId"`
		SenderAvatar string `json:"senderAvatar"`
		Title        string `json:"title"`
		Content      string `json:"content"`
		CreatedAt    int64  `json:"createdAt"`
		IsRead       bool   `json:"isRead"`
		ReferenceID  string `json:"referenceId,omitempty"`
	}

	var response []NotificationResponse = []NotificationResponse{}
	for _, n := range notifications {
		var sender User
		DB.First(&sender, "id = ?", n.SenderID)
		response = append(response, NotificationResponse{
			ID:           n.ID,
			Type:         n.Type,
			SenderID:     n.SenderID,
			SenderAvatar: sender.Avatar,
			Title:        n.Title,
			Content:      n.Content,
			CreatedAt:    n.CreatedAt,
			IsRead:       n.IsRead,
			ReferenceID:  n.ReferenceID,
		})
	}
	c.JSON(200, response)
}

func handleGetNotificationsCount(c *gin.Context) {
	userId := c.Param("userId")
	var count int64
	DB.Model(&Notification{}).Where("user_id = ? AND is_read = ?", userId, false).Count(&count)
	c.JSON(200, gin.H{"count": count})
}

func handleGetNotificationsSummary(c *gin.Context) {
	userId := c.Param("userId")
	var count int64
	DB.Model(&Notification{}).Where("user_id = ? AND is_read = ?", userId, false).Count(&count)
	c.JSON(200, gin.H{"unreadNotifications": count})
}
