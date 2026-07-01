package main

import (
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func initDB() {
	var err error
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL != "" {
		DB, err = gorm.Open(postgres.Open(dbURL), &gorm.Config{})
		if err != nil {
			panic("Error al conectar a la base de datos PostgreSQL: " + err.Error())
		}
		println("Conectado con éxito a PostgreSQL (Producción).")
	} else {
		// SQLite local para desarrollo
		DB, err = gorm.Open(sqlite.Open("guaygo.db"), &gorm.Config{})
		if err != nil {
			panic("Error al conectar a la base de datos SQLite: " + err.Error())
		}
		println("Conectado con éxito a SQLite local (Desarrollo).")
	}

	// Migraciones automáticas de GORM
	DB.AutoMigrate(
		&User{},
		&League{},
		&Friendship{},
		&Message{},
		&Mission{},
		&MissionCompletion{},
		&Vote{},
		&Notification{},
	)
}

func seedMissions() {
	var count int64
	DB.Model(&Mission{}).Count(&count)
	if count == 0 {
		defaultMissions := []Mission{
			{ID: "m1", Title: "Verde", Description: "Toma una foto de algo verde", Points: 10},
			{ID: "m2", Title: "Mascota", Description: "Toma una foto de un perro o gato", Points: 15},
			{ID: "m3", Title: "Café", Description: "Toma una foto de una taza de café", Points: 10},
			{ID: "m4", Title: "Amigos", Description: "Toma una foto con un amigo", Points: 25},
			{ID: "m5", Title: "Cielo", Description: "Toma una foto de un amanecer o atardecer", Points: 20},
			{ID: "m6", Title: "Lectura", Description: "Toma una foto de un libro que estés leyendo", Points: 15},
		}
		for _, m := range defaultMissions {
			DB.Create(&m)
		}
		println("Misiones por defecto sembradas con éxito.")
	}
}

func main() {
	initDB()
	seedMissions()

	// En Render el entorno suele ser Release. En local podemos dejarlo por defecto.
	if os.Getenv("DATABASE_URL") != "" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	r.Use(CORSMiddleware())

	// --- 1. Rutas de Autenticación ---
	r.POST("/api/auth/register", handleRegister)
	r.POST("/api/auth/login", handleLogin)

	// --- 2. Rutas de Usuarios ---
	r.GET("/api/users/:userId/profile", handleGetProfile)
	r.GET("/api/users/:userId/photo-count", handleGetPhotoCount)
	r.GET("/api/users/:userId/suggestions", handleGetSuggestions)
	r.GET("/api/users/search", handleSearchUsers)

	// --- 3. Rutas de Amistad ---
	r.POST("/api/friends/request", handleFriendRequest)
	r.POST("/api/friends/accept", handleFriendAccept)
	r.POST("/api/friends/reject", handleFriendReject)
	r.GET("/api/friends/:userId", handleGetFriends)
	r.GET("/api/friends/:userId/pending", handleGetPendingFriends)
	r.GET("/api/friends/:userId/sent", handleGetSentRequests)

	// --- 4. Rutas de Ligas ---
	r.POST("/api/leagues", handleCreateLeague)
	r.GET("/api/leagues/code/:code", handleGetLeagueByCode)
	r.GET("/api/leagues/id/:leagueId", handleGetLeagueByID)
	r.POST("/api/leagues/:leagueId/join", handleJoinLeague)
	r.GET("/api/leagues/:leagueId/status", handleGetLeagueStatus)
	r.GET("/api/leagues/:leagueId/members", handleGetLeagueMembers)
	r.GET("/api/leagues/public", handleGetPublicLeagues)

	// --- 5. Rutas de Mensajería ---
	r.GET("/api/messages/:leagueId", handleGetLeagueMessages)
	r.POST("/api/messages", handleSendLeagueMessage)
	r.GET("/api/messages/private/:userId/:friendId", handleGetPrivateMessages)
	r.POST("/api/messages/private", handleSendPrivateMessage)
	r.GET("/api/messages/unread/:userId", handleGetUnreadMessages)

	// --- 6. Rutas de Misiones e Historias ---
	r.GET("/api/missions/:leagueId", handleGetMissions)
	r.POST("/api/missions/:missionId/complete", handleCompleteMission)
	r.POST("/api/votes", handlePostVote)
	r.GET("/api/stories/:leagueId", handleGetStories)

	// --- 7. Rutas de Notificaciones ---
	r.GET("/api/notifications/:userId", handleGetNotifications)
	r.GET("/api/notifications/:userId/count", handleGetNotificationsCount)
	r.GET("/api/notifications/:userId/summary", handleGetNotificationsSummary)

	// --- 8. Rutas de Administración ---
	r.POST("/api/admin/missions", handleAdminCreateMission)
	r.GET("/api/admin/users", handleAdminGetAllUsers)

	port := os.Getenv("PORT")
	if port == "" {
		port = "9999"
	}

	println("Servidor escuchando en puerto " + port)
	r.Run(":" + port)
}
