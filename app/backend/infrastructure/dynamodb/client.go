package dynamodb

import (
	"net/http"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

func NewClient(endpoint, region string) (*dynamodb.DynamoDB, error) {
	return NewClientWithTimeout(endpoint, region, 30*time.Second)
}

func NewClientWithTimeout(endpoint, region string, timeout time.Duration) (*dynamodb.DynamoDB, error) {
	// HTTPクライアントにタイムアウト設定を追加
	httpClient := &http.Client{
		Timeout: timeout,
	}

	config := &aws.Config{
		Region:     aws.String(region),
		HTTPClient: httpClient,
	}

	if endpoint != "" {
		config.Endpoint = aws.String(endpoint)
	}

	sess, err := session.NewSession(config)
	if err != nil {
		return nil, err
	}

	return dynamodb.New(sess), nil
}
