package main

import (
	"fmt"
	"log"

	"audio-slide-app/config"
	"audio-slide-app/infrastructure/dynamodb"
	"audio-slide-app/interface/handler"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	cfg := config.NewConfig()

	// DynamoDB接続
	dynamoDBClient, err := dynamodb.NewClient(cfg.DynamoDBEndpoint, cfg.AWSRegion)
	if err != nil {
		log.Fatalf("Failed to create DynamoDB client: %v", err)
	}

	fmt.Println("DynamoDBClientStatus: ", map[string]interface{}{
		"endpoint": cfg.DynamoDBEndpoint,
		"region":   cfg.AWSRegion,
		"dynamodbClient": map[string]interface{}{
			"endpoint":        dynamoDBClient.Endpoint,
			"region":          dynamoDBClient.Config.Region,
			"config_endpoint": dynamoDBClient.Config.Endpoint,
		},
	})

	// リポジトリ初期化
	quizRepo := dynamodb.NewQuizRepository(dynamoDBClient)
	categoryRepo := dynamodb.NewCategoryRepository(dynamoDBClient)

	// ハンドラー初期化
	healthHandler := handler.NewHealthHandler()
	categoryHandler := handler.NewCategoryHandler(categoryRepo)
	quizHandler := handler.NewQuizHandler(quizRepo)

	// Ginルーター設定
	r := gin.Default()

	// CORS設定
	corsConfig := cors.DefaultConfig()
	corsConfig.AllowOrigins = []string{"http://localhost:3000", "https://audio-slide-app.com"}
	corsConfig.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	corsConfig.AllowHeaders = []string{"Content-Type", "Authorization"}
	r.Use(cors.New(corsConfig))

	// ルート設定
	api := r.Group("/api")
	{
		api.GET("/health", healthHandler.GetHealth)
		api.GET("/categories", categoryHandler.GetCategories)
		api.GET("/quiz", quizHandler.GetQuizzes)
		api.GET("/quiz/:id", quizHandler.GetQuizByID)
	}

	// サーバー起動
	port := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Server starting on port %s", cfg.Port)
	if err := r.Run(port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
