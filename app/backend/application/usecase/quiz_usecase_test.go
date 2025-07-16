package usecase

import (
	"context"
	"errors"
	"testing"

	"audio-slide-app/common/errs"
	"audio-slide-app/domain/model"
	mock_repository "audio-slide-app/mocks/repository"

	"github.com/stretchr/testify/assert"
	"go.uber.org/mock/gomock"
)

func TestQuizUseCase_GetQuizzesByCategory(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mock_repository.NewMockIQuizRepository(ctrl)
	usecase := NewQuizUseCase(mockRepo)

	tests := []struct {
		name     string
		category string
		count    int
		setup    func()
		wantErr  bool
		errType  string
	}{
		{
			name:     "正常系_国旗カテゴリ",
			category: "flags",
			count:    5,
			setup: func() {
				quizzes := []*model.Quiz{
					model.NewQuiz("quiz1", "url1", "audio1", "answer1", []string{"answer1", "wrong1"}, "flags", "explanation1"),
				}
				mockRepo.EXPECT().
					GetQuizzesByCategoryToData(gomock.Any(), "flags", 5).
					Return(quizzes, nil).
					Times(1)
			},
			wantErr: false,
		},
		{
			name:     "異常系_無効なカテゴリ",
			category: "invalid",
			count:    5,
			setup:    func() {},
			wantErr:  true,
			errType:  errs.EC001,
		},
		{
			name:     "正常系_カウント調整",
			category: "animals",
			count:    100, // 50を超える値
			setup: func() {
				quizzes := []*model.Quiz{}
				mockRepo.EXPECT().
					GetQuizzesByCategoryToData(gomock.Any(), "animals", 10). // デフォルト値に調整される
					Return(quizzes, nil).
					Times(1)
			},
			wantErr: false,
		},
		{
			name:     "異常系_リポジトリエラー",
			category: "flags",
			count:    5,
			setup: func() {
				mockRepo.EXPECT().
					GetQuizzesByCategoryToData(gomock.Any(), "flags", 5).
					Return(nil, errors.New("database error")).
					Times(1)
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tt.setup()

			result, err := usecase.GetQuizzesByCategory(context.Background(), tt.category, tt.count)

			if tt.wantErr {
				assert.Error(t, err)
				if tt.errType != "" {
					if appErr, ok := err.(*errs.AppError); ok {
						assert.Equal(t, tt.errType, appErr.Code)
					}
				}
				assert.Nil(t, result)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, result)
			}
		})
	}
}

func TestQuizUseCase_GetQuizByID(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mock_repository.NewMockIQuizRepository(ctrl)
	usecase := NewQuizUseCase(mockRepo)

	tests := []struct {
		name    string
		id      string
		setup   func()
		wantErr bool
		errType string
	}{
		{
			name: "正常系",
			id:   "quiz_001",
			setup: func() {
				quiz := model.NewQuiz("quiz_001", "url", "audio", "answer", []string{"answer"}, "flags", "explanation")
				mockRepo.EXPECT().
					GetQuizByIDToData(gomock.Any(), "quiz_001").
					Return(quiz, nil).
					Times(1)
			},
			wantErr: false,
		},
		{
			name:    "異常系_空のID",
			id:      "",
			setup:   func() {},
			wantErr: true,
			errType: errs.EC001,
		},
		{
			name: "異常系_クイズが見つからない",
			id:   "nonexistent",
			setup: func() {
				mockRepo.EXPECT().
					GetQuizByIDToData(gomock.Any(), "nonexistent").
					Return(nil, errs.NewNotFoundError("quiz not found")).
					Times(1)
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tt.setup()

			result, err := usecase.GetQuizByID(context.Background(), tt.id)

			if tt.wantErr {
				assert.Error(t, err)
				if tt.errType != "" {
					if appErr, ok := err.(*errs.AppError); ok {
						assert.Equal(t, tt.errType, appErr.Code)
					}
				}
				assert.Nil(t, result)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, result)
			}
		})
	}
}
