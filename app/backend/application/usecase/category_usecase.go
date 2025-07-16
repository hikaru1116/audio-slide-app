//go:generate mockgen -source=$GOFILE -destination=../../mocks/usecase/mock_$GOFILE -package=mock_usecase

package usecase

import (
	"context"

	"audio-slide-app/domain/model"
	"audio-slide-app/domain/repository"
)

type ICategoryUseCase interface {
	GetCategories(ctx context.Context) ([]*model.Category, error)
}

type CategoryUseCase struct {
	categoryRepo repository.ICategoryRepository
}

func NewCategoryUseCase(categoryRepo repository.ICategoryRepository) ICategoryUseCase {
	return &CategoryUseCase{
		categoryRepo: categoryRepo,
	}
}

func (uc *CategoryUseCase) GetCategories(ctx context.Context) ([]*model.Category, error) {
	return uc.categoryRepo.GetCategoriesToData(ctx)
}
