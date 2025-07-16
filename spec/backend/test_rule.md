# コンテンツサービス 単体テストルール

## 基本方針

コンテンツサービスでは、以下の原則に従って単体テストを実装します：

1. **依存性の分離**: 外部依存（データベース、API 等）に依存しないテストを書く
2. **モックの活用**: インターフェースに対してモックを使用し、依存コンポーネントを置き換える
3. **テストケースの網羅**: 正常系・異常系の両方をテストする
4. **テストの可読性**: テスト内容が明確に理解できるようにする

## テストカバレッジ

各パッケージのテストカバレッジは 80%以上を目指します。

## テスト環境

- テストフレームワーク: Go 標準の`testing`パッケージ
- アサーションライブラリ: `github.com/stretchr/testify/assert`
- モックライブラリ: `go.uber.org/mock/gomock`

## テストファイル配置

- テスト対象のファイルと同じディレクトリに`_test.go`の接尾辞を付けたファイルを配置
- 例: `domain/model/playbyplay.go` → `domain/model/playbyplay_test.go`

## モック生成ルール

1. インターフェースを定義したファイルに以下のコメントを追加:

```go
//go:generate mockgen -source=$GOFILE -destination=../../mocks/$GOPACKAGE/mock_$GOFILE -package=mock_$GOPACKAGE
```

2. モック生成コマンドを実行:

```bash
make mocks
```

これにより、`mocks/[パッケージ名]/`ディレクトリ以下にモックが生成されます。

## テストケース作成パターン

### テーブル駆動テスト

```go
func TestXxx(t *testing.T) {
	tests := []struct {
		name    string      // テストケース名
		input   SomeType    // 入力値
		want    ResultType  // 期待する結果
		wantErr bool        // エラーを期待するか
	}{
		{
			name:    "正常系",
			input:   SomeValue,
			want:    ExpectedResult,
			wantErr: false,
		},
		{
			name:    "異常系",
			input:   InvalidValue,
			want:    ZeroValue,
			wantErr: true,
		},
		// 他のテストケース...
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// テスト実行
			got, err := FunctionToTest(tt.input)

			// アサーション
			if (err != nil) != tt.wantErr {
				t.Errorf("error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			assert.Equal(t, tt.want, got)
		})
	}
}
```

### モック使用パターン

```go
func TestWithMock(t *testing.T) {
	// 前準備
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	// モックの生成
	mockRepo := mock_repository.NewMockIRepository(ctrl)

	// モックの期待値設定
	mockRepo.EXPECT().
		SomeMethod(gomock.Any(), "param").
		Return(expectedResult, nil).
		Times(1)

	// テスト対象の生成（モックを注入）
	sut := service.NewService(mockRepo)

	// 実行
	result, err := sut.DoSomething(context.Background(), "param")

	// アサーション
	assert.NoError(t, err)
	assert.Equal(t, expectedResult, result)
}
```

## エラーテスト

エラーのアサーションには、以下のパターンを使用します：

```go
// エラーの有無をチェック
assert.Error(t, err)
assert.NoError(t, err)

// エラーメッセージをチェック
assert.EqualError(t, err, "expected error message")

// カスタムエラーのチェック
assert.IsType(t, &CustomError{}, err)
```

## テスト実行方法

### すべてのテストを実行

```bash
go test -v ./...
```

### 特定のパッケージのテストを実行

```bash
go test -v ./[パッケージパス]
```

### 特定のテストを実行

```bash
go test -v -run TestXxx ./[パッケージパス]
```

## カバレッジ計測

```bash
go test -cover ./...
```

詳細なカバレッジレポートを生成する場合：

```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## ユニットテスト作成時の注意点

1. 副作用のあるコードは適切にモックすること
2. 時間に依存するコードは、時間を注入可能な設計にすること
3. ランダム性のあるロジックは、テスト時に固定値を使用できるようにすること
4. グローバル状態に依存しないこと
5. テスト対象の機能のみをテストし、内部実装の詳細にカップリングしないこと
