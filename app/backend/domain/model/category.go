package model

type Category struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Thumbnail   string `json:"thumbnail"`
}

func NewCategory(id, name, description, thumbnail string) *Category {
	return &Category{
		ID:          id,
		Name:        name,
		Description: description,
		Thumbnail:   thumbnail,
	}
}