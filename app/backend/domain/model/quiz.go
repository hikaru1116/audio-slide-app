package model

import (
	"time"
)

type Quiz struct {
	ID               string    `json:"id" dynamodbav:"id"`
	QuestionImageURL string    `json:"questionImageUrl" dynamodbav:"questionImageUrl"`
	QuestionAudioURL string    `json:"questionAudioUrl" dynamodbav:"questionAudioUrl"`
	CorrectAnswer    string    `json:"correctAnswer" dynamodbav:"correctAnswer"`
	Choices          []string  `json:"choices" dynamodbav:"choices"`
	Category         string    `json:"category" dynamodbav:"category"`
	Explanation      string    `json:"explanation" dynamodbav:"explanation"`
	CreatedAt        time.Time `json:"createdAt" dynamodbav:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt" dynamodbav:"updatedAt"`
	PK               string    `json:"-" dynamodbav:"PK"`
	SK               string    `json:"-" dynamodbav:"SK"`
}

func NewQuiz(id, questionImageURL, questionAudioURL, correctAnswer string, choices []string, category, explanation string) *Quiz {
	now := time.Now()
	return &Quiz{
		ID:               id,
		QuestionImageURL: questionImageURL,
		QuestionAudioURL: questionAudioURL,
		CorrectAnswer:    correctAnswer,
		Choices:          choices,
		Category:         category,
		Explanation:      explanation,
		CreatedAt:        now,
		UpdatedAt:        now,
		PK:               "CATEGORY#" + category,
		SK:               "QUIZ#" + id,
	}
}