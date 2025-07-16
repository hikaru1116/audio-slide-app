//go:generate mockgen -source=$GOFILE -destination=../../mocks/usecase/mock_$GOFILE -package=mock_usecase

package usecase

import (
	"context"

	"audio-slide-app/common/errs"
	"audio-slide-app/domain/model"
	"audio-slide-app/domain/repository"
)

type IQuizUseCase interface {
	GetQuizzesByCategory(ctx context.Context, category string, count int) ([]*model.Quiz, error)
	GetQuizByID(ctx context.Context, id string) (*model.Quiz, error)
}

type QuizUseCase struct {
	quizRepo repository.IQuizRepository
}

func NewQuizUseCase(quizRepo repository.IQuizRepository) IQuizUseCase {
	return &QuizUseCase{
		quizRepo: quizRepo,
	}
}

func (uc *QuizUseCase) GetQuizzesByCategory(ctx context.Context, category string, count int) ([]*model.Quiz, error) {
	// カテゴリのバリデーション
	validCategories := map[string]bool{
		"flags":   true,
		"animals": true,
		"words":   true,
	}

	if !validCategories[category] {
		return nil, errs.NewBadRequestError("invalid category specified")
	}

	// カウントのバリデーション
	if count < 1 || count > 50 {
		count = 10 // デフォルト値
	}

	return uc.quizRepo.GetQuizzesByCategoryToData(ctx, category, count)
}

func (uc *QuizUseCase) GetQuizByID(ctx context.Context, id string) (*model.Quiz, error) {
	if id == "" {
		return nil, errs.NewBadRequestError("quiz id is required")
	}

	return uc.quizRepo.GetQuizByIDToData(ctx, id)
}
