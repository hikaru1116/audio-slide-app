//go:generate mockgen -source=$GOFILE -destination=../../mocks/repository/mock_$GOFILE -package=mock_repository

package repository

import (
	"context"

	"audio-slide-app/domain/model"
)

type IQuizRepository interface {
	GetQuizzesByCategoryToData(ctx context.Context, category string, count int) ([]*model.Quiz, error)
	GetQuizByIDToData(ctx context.Context, id string) (*model.Quiz, error)
}
