//go:generate mockgen -source=$GOFILE -destination=../../mocks/repository/mock_$GOFILE -package=mock_repository

package repository

import (
	"context"

	"audio-slide-app/domain/model"
)

type ICategoryRepository interface {
	GetCategoriesToData(ctx context.Context) ([]*model.Category, error)
}
