package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func normalizeDatabaseURL(dbURL string) string {
	dbURL = strings.TrimSpace(dbURL)
	if dbURL == "" {
		return dbURL
	}
	if !strings.Contains(dbURL, "sslmode=") {
		if strings.Contains(dbURL, "?") {
			return dbURL + "&sslmode=require"
		}
		return dbURL + "?sslmode=require"
	}
	return dbURL
}

func initDB() {
	var err error
	dbURL := normalizeDatabaseURL(os.Getenv("DATABASE_URL"))
	fmt.Printf("DATABASE_URL presente: %v\n", dbURL != "")

	if dbURL != "" {
		DB, err = gorm.Open(postgres.Open(dbURL), &gorm.Config{})
		if err != nil {
			panic("Error al conectar a la base de datos PostgreSQL: " + err.Error())
		}
		println("Conectado con éxito a PostgreSQL (Producción).")
	} else {
		DB, err = gorm.Open(sqlite.Open("guaygo.db"), &gorm.Config{})
		if err != nil {
			panic("Error al conectar a la base de datos SQLite: " + err.Error())
		}
		println("Conectado con éxito a SQLite local (Desarrollo).")
	}

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

	if os.Getenv("DATABASE_URL") != "" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	r.Use(CORSMiddleware())

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"app":     "GuayApp Backend",
			"status":  "online",
			"version": "1.0.1",
			"docs":    "https://guay-app-social.web.app/admin.html",
		})
	})
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	r.POST("/api/auth/register", handleRegister)
	r.POST("/api/auth/login", handleLogin)

	r.GET("/api/users/:userId/profile", handleGetProfile)
	r.GET("/api/users/:userId/photo-count", handleGetPhotoCount)
	r.GET("/api/users/:userId/suggestions", handleGetSuggestions)
	r.GET("/api/users/search", handleSearchUsers)

	r.POST("/api/friends/request", handleFriendRequest)
	r.POST("/api/friends/accept", handleFriendAccept)
	r.POST("/api/friends/reject", handleFriendReject)
	r.GET("/api/friends/:userId", handleGetFriends)
	r.GET("/api/friends/:userId/pending", handleGetPendingFriends)
	r.GET("/api/friends/:userId/sent", handleGetSentRequests)

	r.POST("/api/leagues", handleCreateLeague)
	r.GET("/api/leagues/code/:code", handleGetLeagueByCode)
	r.GET("/api/leagues/id/:leagueId", handleGetLeagueByID)
	r.POST("/api/leagues/:leagueId/join", handleJoinLeague)
	r.GET("/api/leagues/:leagueId/status", handleGetLeagueStatus)
	r.GET("/api/leagues/:leagueId/members", handleGetLeagueMembers)
	r.GET("/api/leagues/public", handleGetPublicLeagues)

	r.GET("/api/messages/:leagueId", handleGetLeagueMessages)
	r.POST("/api/messages", handleSendLeagueMessage)
	r.GET("/api/messages/private/:userId/:friendId", handleGetPrivateMessages)
	r.POST("/api/messages/private", handleSendPrivateMessage)
	r.GET("/api/messages/unread/:userId", handleGetUnreadMessages)

	r.GET("/api/missions/:leagueId", handleGetMissions)
	r.POST("/api/missions/:missionId/complete", handleCompleteMission)
	r.POST("/api/votes", handlePostVote)
	r.GET("/api/stories/:leagueId", handleGetStories)

	r.GET("/api/notifications/:userId", handleGetNotifications)
	r.GET("/api/notifications/:userId/count", handleGetNotificationsCount)
	r.GET("/api/notifications/:userId/summary", handleGetNotificationsSummary)
	r.POST("/api/notifications/:userId/mark-all-read", handleMarkAllNotificationsRead)

	r.POST("/api/admin/missions", handleAdminCreateMission)
	r.GET("/api/admin/users", handleAdminGetAllUsers)

	port := os.Getenv("PORT")
	if port == "" {
		port = "9999"
	}

	println("Servidor escuchando en puerto " + port)
	r.Run(":" + port)
}
