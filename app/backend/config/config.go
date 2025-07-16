package config

import (
	"os"
)

type Config struct {
	DynamoDBEndpoint string
	AWSRegion        string
	Port             string
}

func NewConfig() *Config {
	return &Config{
		DynamoDBEndpoint: getEnv("DYNAMODB_ENDPOINT", ""),
		AWSRegion:        getEnv("AWS_REGION", "ap-northeast-1"),
		Port:             getEnv("PORT", "8080"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}