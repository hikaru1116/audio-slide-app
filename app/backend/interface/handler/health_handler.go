package handler

import (
	"net/http"

	"audio-slide-app/domain/dto"

	"github.com/gin-gonic/gin"
)

type HealthHandler struct{}

func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

func (h *HealthHandler) GetHealth(c *gin.Context) {
	response := dto.NewHealthResponse()
	c.JSON(http.StatusOK, response)
}