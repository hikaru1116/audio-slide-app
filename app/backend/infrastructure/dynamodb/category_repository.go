package dynamodb

import (
	"context"

	"audio-slide-app/domain/model"
	"audio-slide-app/domain/repository"

	"github.com/aws/aws-sdk-go/service/dynamodb"
)

type CategoryRepository struct {
	client *dynamodb.DynamoDB
}

func NewCategoryRepository(client *dynamodb.DynamoDB) repository.ICategoryRepository {
	return &CategoryRepository{
		client: client,
	}
}

func (r *CategoryRepository) GetCategoriesToData(ctx context.Context) ([]*model.Category, error) {
	// 固定のカテゴリを返す（実際の実装では、DynamoDBから取得）
	categories := []*model.Category{
		model.NewCategory("flags", "国旗", "世界各国の国旗を学習", "https://cdn.example.com/thumbnails/flags.jpg"),
		model.NewCategory("animals", "動物", "様々な動物を学習", "https://cdn.example.com/thumbnails/animals.jpg"),
		model.NewCategory("words", "言葉", "基本的な単語を学習", "https://cdn.example.com/thumbnails/words.jpg"),
	}

	return categories, nil
}
