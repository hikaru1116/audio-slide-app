package dto

import (
	"time"
)

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
}

func NewHealthResponse() *HealthResponse {
	return &HealthResponse{
		Status:    "ok",
		Timestamp: time.Now(),
	}
}