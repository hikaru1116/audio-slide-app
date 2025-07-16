package dynamodb

import (
	"context"
	"fmt"
	"math/rand"

	"audio-slide-app/common/errs"
	"audio-slide-app/domain/model"
	"audio-slide-app/domain/repository"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

const (
	QuizTableName = "Quiz"
)

type QuizRepository struct {
	client *dynamodb.DynamoDB
}

func NewQuizRepository(client *dynamodb.DynamoDB) repository.IQuizRepository {
	return &QuizRepository{
		client: client,
	}
}

func (r *QuizRepository) GetQuizzesByCategoryToData(ctx context.Context, category string, count int) ([]*model.Quiz, error) {
	input := &dynamodb.QueryInput{
		TableName:              aws.String(QuizTableName),
		KeyConditionExpression: aws.String("PK = :pk"),
		ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{
			":pk": {
				S: aws.String(fmt.Sprintf("CATEGORY#%s", category)),
			},
		},
	}

	result, err := r.client.QueryWithContext(ctx, input)
	if err != nil {
		return nil, errs.NewInternalServerError(fmt.Errorf("failed to query quizzes: %w", err))
	}

	var quizzes []*model.Quiz
	for _, item := range result.Items {
		var quiz model.Quiz
		if err := dynamodbattribute.UnmarshalMap(item, &quiz); err != nil {
			return nil, errs.NewInternalServerError(fmt.Errorf("failed to unmarshal quiz: %w", err))
		}
		quizzes = append(quizzes, &quiz)
	}

	// ランダムにシャッフル
	r.shuffleQuizzes(quizzes)

	// 指定された数まで制限
	if count > 0 && count < len(quizzes) {
		quizzes = quizzes[:count]
	}

	return quizzes, nil
}

func (r *QuizRepository) GetQuizByIDToData(ctx context.Context, id string) (*model.Quiz, error) {
	// IDからカテゴリを特定する必要がある（実際の実装では、GSIまたは別の方法を使用）
	// ここでは簡単な実装として、全カテゴリを検索
	categories := []string{"flags", "animals", "words"}

	for _, category := range categories {
		input := &dynamodb.GetItemInput{
			TableName: aws.String(QuizTableName),
			Key: map[string]*dynamodb.AttributeValue{
				"PK": {
					S: aws.String(fmt.Sprintf("CATEGORY#%s", category)),
				},
				"SK": {
					S: aws.String(fmt.Sprintf("QUIZ#%s", id)),
				},
			},
		}

		result, err := r.client.GetItemWithContext(ctx, input)
		if err != nil {
			continue
		}

		if result.Item != nil {
			var quiz model.Quiz
			if err := dynamodbattribute.UnmarshalMap(result.Item, &quiz); err != nil {
				return nil, errs.NewInternalServerError(fmt.Errorf("failed to unmarshal quiz: %w", err))
			}
			return &quiz, nil
		}
	}

	return nil, errs.NewNotFoundError(fmt.Sprintf("quiz with id '%s' not found", id))
}

func (r *QuizRepository) shuffleQuizzes(quizzes []*model.Quiz) {
	for i := len(quizzes) - 1; i > 0; i-- {
		j := rand.Intn(i + 1)
		quizzes[i], quizzes[j] = quizzes[j], quizzes[i]
	}
}
