package transaction

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"time"
)

type SOSTransaction struct {
	EventID   string `json:"eventId"`
	UserID    string `json:"userId"`
	Timestamp int64  `json:"timestamp"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Hash      string `json:"hash"`
}

func NewSOSTransaction(eventID, userID string, lat, lng float64) *SOSTransaction {
	tx := &SOSTransaction{
		EventID:   eventID,
		UserID:    userID,
		Timestamp: time.Now().Unix(),
		Latitude:  lat,
		Longitude: lng,
	}
	tx.Hash = tx.CalculateHash()
	return tx
}

func (t *SOSTransaction) CalculateHash() string {
	record := struct {
		EventID   string
		UserID    string
		Timestamp int64
		Latitude  float64
		Longitude float64
	}{
		EventID:   t.EventID,
		UserID:    t.UserID,
		Timestamp: t.Timestamp,
		Latitude:  t.Latitude,
		Longitude: t.Longitude,
	}

	bytes, _ := json.Marshal(record)
	hash := sha256.Sum256(bytes)
	return hex.EncodeToString(hash[:])
}

func (t *SOSTransaction) ToJSON() string {
	bytes, _ := json.Marshal(t)
	return string(bytes)
}
