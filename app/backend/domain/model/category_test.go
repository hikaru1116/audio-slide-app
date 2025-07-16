package model

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewCategory(t *testing.T) {
	tests := []struct {
		name        string
		id          string
		categoryName string
		description string
		thumbnail   string
	}{
		{
			name:        "正常系_国旗カテゴリ",
			id:          "flags",
			categoryName: "国旗",
			description: "世界各国の国旗を学習",
			thumbnail:   "https://example.com/thumbnails/flags.jpg",
		},
		{
			name:        "正常系_動物カテゴリ",
			id:          "animals",
			categoryName: "動物",
			description: "様々な動物を学習",
			thumbnail:   "https://example.com/thumbnails/animals.jpg",
		},
		{
			name:        "正常系_言葉カテゴリ",
			id:          "words",
			categoryName: "言葉",
			description: "基本的な単語を学習",
			thumbnail:   "https://example.com/thumbnails/words.jpg",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			category := NewCategory(tt.id, tt.categoryName, tt.description, tt.thumbnail)

			assert.Equal(t, tt.id, category.ID)
			assert.Equal(t, tt.categoryName, category.Name)
			assert.Equal(t, tt.description, category.Description)
			assert.Equal(t, tt.thumbnail, category.Thumbnail)
		})
	}
}