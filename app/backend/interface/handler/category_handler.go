package handler

import (
	"net/http"

	"audio-slide-app/application/usecase"
	"audio-slide-app/domain/repository"

	"github.com/gin-gonic/gin"
)

type CategoryHandler struct {
	categoryUseCase usecase.ICategoryUseCase
}

func NewCategoryHandler(categoryRepo repository.ICategoryRepository) *CategoryHandler {
	categoryUseCase := usecase.NewCategoryUseCase(categoryRepo)
	return &CategoryHandler{
		categoryUseCase: categoryUseCase,
	}
}

func (h *CategoryHandler) GetCategories(c *gin.Context) {
	categories, err := h.categoryUseCase.GetCategories(c.Request.Context())
	if err != nil {
		HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, categories)
}
