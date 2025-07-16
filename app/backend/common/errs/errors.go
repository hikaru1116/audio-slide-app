package errs

import (
	"fmt"
)

const (
	EC001 = "EC001"
	EC002 = "EC002"
	EC003 = "EC003"
)

var (
	EC001Message = "リクエストパラメータエラー"
	EC002Message = "リソースが見つからない"
	EC003Message = "内部サーバーエラー"
)

type AppError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details string `json:"details,omitempty"`
	Err     error  `json:"-"`
}

func (e *AppError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("[%s] %s: %v", e.Code, e.Message, e.Err)
	}
	return fmt.Sprintf("[%s] %s", e.Code, e.Message)
}

func NewError(code, message string, err error) *AppError {
	details := ""
	if err != nil {
		details = err.Error()
	}
	return &AppError{
		Code:    code,
		Message: message,
		Details: details,
		Err:     err,
	}
}

func NewBadRequestError(details string) *AppError {
	return &AppError{
		Code:    EC001,
		Message: EC001Message,
		Details: details,
	}
}

func NewNotFoundError(details string) *AppError {
	return &AppError{
		Code:    EC002,
		Message: EC002Message,
		Details: details,
	}
}

func NewInternalServerError(err error) *AppError {
	details := ""
	if err != nil {
		details = err.Error()
	}
	return &AppError{
		Code:    EC003,
		Message: EC003Message,
		Details: details,
		Err:     err,
	}
}