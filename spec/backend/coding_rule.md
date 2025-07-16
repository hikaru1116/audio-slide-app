# コンテンツサービス コーディング規約

## 基本方針

コンテンツサービスでは、以下の方針に基づいてコードを記述します：

1. **クリーンアーキテクチャの遵守**: レイヤー間の依存関係は内側に向かうようにする
2. **責務の明確化**: 各コンポーネントの責務を明確に分離する
3. **テスト容易性**: コードは単体テストが容易な設計にする
4. **一貫性**: 命名規則やコードスタイルを一貫させる

## ディレクトリ構成とレイヤー

本アプリのアーキテクチャ、ディレクトリ構成は、[arch.md](./arch.md)を参照する。

## 命名規則

### パッケージ

- 全て小文字で単数形を使用
  - 例: `model`, `repository`, `handler`

### ファイル

- スネークケースを使用
  - 例: `user_repository.go`, `content_type.go`
- テストファイルは `_test.go` の接尾辞を付与
  - 例: `user_repository_test.go`

### インターフェース

- `I` + キャメルケースで始める
  - 例: `IUserRepository`, `IAuthenticationService`

### 構造体

- キャメルケースを使用
  - 例: `User`, `ContentType`
- ハンドラーは `Handler` の接尾辞を付与
  - 例: `UserHandler`, `ContentHandler`
- リポジトリ実装は `Repository` の接尾辞を付与
  - 例: `UserRepository`, `ContentRepository`
- ユースケースは `UseCase` の接尾辞を付与
  - 例: `AuthenticationUseCase`
- サービスは `Service` の接尾辞を付与
  - 例: `ValidationService`

### 関数・メソッド

- キャメルケースを使用
  - 例: `GetUser()`, `CreateContent()`
- メソッドは動詞で始める
  - 例: `Find()`, `Save()`, `Delete()`
- メソッド名は機能を明確に表す
  - 例: `GetUserByID()`, `UpdatePlayData()`

### 変数

- キャメルケースを使用
  - 例: `user`, `contentType`
- 明確で説明的な名前を使用
  - 例: `userID`, `contentTitle` (短縮形を避ける)

### 定数

- キャメルケースを使用
  - 例: `MaxRetryCount`, `DefaultTimeout`
- エラーコード定義は大文字のスネークケースを使用
  - 例: `EC015`, `NOT_FOUND_ERR`

## コードスタイル

### インポート

- 標準ライブラリ、外部パッケージ、内部パッケージの順にグループ化
- アルファベット順に整列

```go
import (
    // 標準ライブラリ
    "context"
    "fmt"
    "net/http"

    // 外部パッケージ
    "github.com/cockroachdb/errors"
    "github.com/stretchr/testify/assert"

    // 内部パッケージ
    "contents-service/common/errs"
    "contents-service/domain/model"
)
```

### エラー処理

- エラーを明示的に処理し、適切にラップする
- エラーコードは `common/errs` パッケージに定義
- エラーメッセージは日本語で統一

```go
if err != nil {
    return errs.NewError(errs.EC015, errs.EC015Message, fmt.Errorf("gamePK is required"))
}
```

### コメント

- 公開関数・メソッドには常にコメントを付ける
- 処理内容が理解しにくい場合は、必ず補足コメントを付ける

```go
// UpdatePlayData プレイデータ更新API
//
func (h *UpdatePlayDataHandler) UpdatePlayData(w http.ResponseWriter, r *http.Request) {
    // ...
}
```

### ログ

- コンテキストからロガーを取得
- ログレベルを適切に使い分ける
- 構造化ログを活用する

```go
logger := log.FromContext(ctx)
logger.Info(fmt.Sprintf("[playByplayデータ更新] 処理開始: gamePK: %d", req.GamePK))
logger.InfoMap(map[string]interface{}{
    "resource": "update_play_data",
    "action":   "start",
    "gamePK":   req.GamePK,
})
```

## パターン

### 依存性注入

- コンストラクタインジェクションを使用
- モックしやすい設計にする

```go
func NewUpdatePlayDataHandler(
    updu usecase.IUpdatePlayDataUseCase,
    trcu usecase.ITracingUseCase,
) *UpdatePlayDataHandler {
    return &UpdatePlayDataHandler{
        updatePlayDataUseCase: updu,
        tracingUseCase:        trcu,
    }
}
```

### リクエスト検証

- ハンドラで入力バリデーションを実施
- 専用のバリデーションメソッドを用意

```go
func (h *UpdatePlayDataHandler) validateRequestParam(req UpdatePlayDataRequest) error {
    if req.GamePK == 0 {
        return errs.NewError(errs.EC015, errs.EC015Message, fmt.Errorf("gamePK is required"))
    }
    if len(req.GuidList) == 0 {
        return errs.NewError(errs.EC017, errs.EC017Message, fmt.Errorf("guidList is required"))
    }
    return nil
}
```

## 単体テスト

単体テストのルールについては、[test_rule.md](./test_rule.md)を参照する。
