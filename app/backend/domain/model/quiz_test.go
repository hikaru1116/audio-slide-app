package model

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewQuiz(t *testing.T) {
	tests := []struct {
		name             string
		id               string
		questionImageURL string
		questionAudioURL string
		correctAnswer    string
		choices          []string
		category         string
		explanation      string
		wantPK           string
		wantSK           string
	}{
		{
			name:             "正常系_国旗クイズ",
			id:               "quiz_flag_001",
			questionImageURL: "https://example.com/flags/italy.svg",
			questionAudioURL: "https://example.com/audio/italy.mp3",
			correctAnswer:    "イタリア",
			choices:          []string{"イタリア", "フランス", "ドイツ", "スペイン"},
			category:         "flags",
			explanation:      "イタリアの国旗は緑、白、赤の三色旗です。",
			wantPK:           "CATEGORY#flags",
			wantSK:           "QUIZ#quiz_flag_001",
		},
		{
			name:             "正常系_動物クイズ",
			id:               "quiz_animal_001",
			questionImageURL: "https://example.com/animals/lion.jpg",
			questionAudioURL: "https://example.com/audio/lion.mp3",
			correctAnswer:    "ライオン",
			choices:          []string{"ライオン", "トラ", "ヒョウ", "チーター"},
			category:         "animals",
			explanation:      "ライオンは百獣の王と呼ばれる大型の肉食動物です。",
			wantPK:           "CATEGORY#animals",
			wantSK:           "QUIZ#quiz_animal_001",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			quiz := NewQuiz(
				tt.id,
				tt.questionImageURL,
				tt.questionAudioURL,
				tt.correctAnswer,
				tt.choices,
				tt.category,
				tt.explanation,
			)

			assert.Equal(t, tt.id, quiz.ID)
			assert.Equal(t, tt.questionImageURL, quiz.QuestionImageURL)
			assert.Equal(t, tt.questionAudioURL, quiz.QuestionAudioURL)
			assert.Equal(t, tt.correctAnswer, quiz.CorrectAnswer)
			assert.Equal(t, tt.choices, quiz.Choices)
			assert.Equal(t, tt.category, quiz.Category)
			assert.Equal(t, tt.explanation, quiz.Explanation)
			assert.Equal(t, tt.wantPK, quiz.PK)
			assert.Equal(t, tt.wantSK, quiz.SK)
			assert.NotZero(t, quiz.CreatedAt)
			assert.NotZero(t, quiz.UpdatedAt)
			assert.Equal(t, quiz.CreatedAt, quiz.UpdatedAt)
		})
	}
}
