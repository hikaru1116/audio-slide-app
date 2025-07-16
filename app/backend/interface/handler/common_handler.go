package handler

import (
	"net/http"

	"audio-slide-app/common/errs"
	"audio-slide-app/domain/dto"

	"github.com/gin-gonic/gin"
)

// HandleError は共通のエラーハンドラー関数です
func HandleError(c *gin.Context, err error) {
	if appErr, ok := err.(*errs.AppError); ok {
		statusCode := http.StatusInternalServerError
		switch appErr.Code {
		case errs.EC001:
			statusCode = http.StatusBadRequest
		case errs.EC002:
			statusCode = http.StatusNotFound
		case errs.EC003:
			statusCode = http.StatusInternalServerError
		}

		response := dto.NewErrorResponse(appErr.Code, appErr.Message, appErr.Details)
		c.JSON(statusCode, response)
		return
	}

	// 未知のエラー
	response := dto.NewErrorResponse(errs.EC003, errs.EC003Message, err.Error())
	c.JSON(http.StatusInternalServerError, response)
}
