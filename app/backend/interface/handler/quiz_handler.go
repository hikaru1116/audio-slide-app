package handler

import (
	"fmt"
	"net/http"
	"strconv"

	"audio-slide-app/application/usecase"
	"audio-slide-app/common/errs"
	"audio-slide-app/domain/repository"

	"github.com/gin-gonic/gin"
)

type QuizHandler struct {
	quizUseCase usecase.IQuizUseCase
}

func NewQuizHandler(quizRepo repository.IQuizRepository) *QuizHandler {
	quizUseCase := usecase.NewQuizUseCase(quizRepo)
	return &QuizHandler{
		quizUseCase: quizUseCase,
	}
}

func (h *QuizHandler) GetQuizzes(c *gin.Context) {
	category := c.Query("category")
	if category == "" {
		HandleError(c, errs.NewBadRequestError("category parameter is required"))
		return
	}

	countStr := c.Query("count")
	count := 10 // デフォルト値

	if countStr != "" {
		if parsedCount, err := strconv.Atoi(countStr); err == nil {
			count = parsedCount
		}
	}

	quizzes, err := h.quizUseCase.GetQuizzesByCategory(c.Request.Context(), category, count)
	if err != nil {
		fmt.Println(fmt.Errorf("GetQuizzesByCategoryError: %w", err))
		HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, quizzes)
}

func (h *QuizHandler) GetQuizByID(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		HandleError(c, errs.NewBadRequestError("quiz id is required"))
		return
	}

	quiz, err := h.quizUseCase.GetQuizByID(c.Request.Context(), id)
	if err != nil {
		HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, quiz)
}
