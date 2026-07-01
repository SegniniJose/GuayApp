package main

type User struct {
	ID        string `gorm:"primaryKey" json:"id"`
	Username  string `gorm:"uniqueIndex;not null" json:"username"`
	Email     string `gorm:"uniqueIndex;not null" json:"email"`
	Password  string `gorm:"not null" json:"-"`
	LeagueID  string `json:"leagueId"`
	Avatar    string `json:"avatar"`
	Points    int    `gorm:"default:0" json:"points"`
	IsPrivate bool   `gorm:"default:true" json:"isPrivate"`
}

type League struct {
	ID              string `gorm:"primaryKey" json:"id"`
	Name            string `gorm:"not null" json:"name"`
	Code            string `gorm:"uniqueIndex;not null" json:"code"`
	AdminID         string `gorm:"not null" json:"adminId"`
	IsPublic        bool   `gorm:"default:true" json:"isPublic"`
	DurationDays    *int   `json:"durationDays,omitempty"`
	DurationMinutes *int   `json:"durationMinutes,omitempty"`
	VenueName       string `json:"venueName,omitempty"`
	Status          string `gorm:"default:'active'" json:"status"`
}

type Friendship struct {
	ID       string `gorm:"primaryKey" json:"id"`
	UserID   string `gorm:"index" json:"userId"` // requester
	FriendID string `gorm:"index" json:"friendId"` // receiver
	Status   string `gorm:"default:'pending'" json:"status"` // 'pending', 'accepted'
}

type Message struct {
	ID         string `gorm:"primaryKey" json:"id"`
	LeagueID   string `gorm:"index" json:"leagueId,omitempty"`
	SenderID   string `gorm:"index;not null" json:"senderId"`
	ReceiverID string `gorm:"index" json:"receiverId,omitempty"`
	Content    string `gorm:"not null" json:"content"`
	Type       string `gorm:"default:'text'" json:"type"`
	Timestamp  int64  `json:"timestamp"` // Unix ms
}

type Mission struct {
	ID          string `gorm:"primaryKey" json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Points      int    `json:"points"`
}

type MissionCompletion struct {
	ID        string `gorm:"primaryKey" json:"id"`
	MissionID string `gorm:"index;not null" json:"missionId"`
	LeagueID  string `gorm:"index;not null" json:"leagueId"`
	UserID    string `gorm:"index;not null" json:"userId"`
	PhotoURL  string `gorm:"type:text" json:"photoUrl"` // base64 SVG
	Status    string `gorm:"default:'pending_validation'" json:"status"` // 'pending_validation', 'validated', 'rejected'
}

type Vote struct {
	ID                  string `gorm:"primaryKey" json:"id"`
	UserID              string `gorm:"index;not null" json:"userId"`
	MissionCompletionID string `gorm:"index;not null" json:"missionCompletionId"`
	IsValid             bool   `json:"isValid"`
}

type Notification struct {
	ID           string `gorm:"primaryKey" json:"id"`
	UserID       string `gorm:"index;not null" json:"userId"` // recipient
	SenderID     string `json:"senderId"`
	Type         string `json:"type"` // 'friend_request', 'private_message', 'validation'
	ReferenceID  string `json:"referenceId,omitempty"` // friendshipId or missionCompletionId
	Title        string `json:"title"`
	Content      string `json:"content"`
	IsRead       bool   `gorm:"default:false" json:"isRead"`
	CreatedAt    int64  `json:"createdAt"` // Unix ms
}
