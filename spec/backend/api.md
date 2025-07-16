# 音声スライド学習アプリ API 仕様書

## 概要

本仕様書は、音声スライド学習 Web アプリケーションのバックエンド API 仕様を定義します。
この API は、国旗、動物、言葉等のカテゴリに基づいた学習コンテンツを提供し、
画像、テキスト、音声を組み合わせた学習体験を支援します。

## 共通仕様

### ベース URL

- 本番環境: `https://api.audio-slide-app.com`
- 開発環境: `http://localhost:8080`

### HTTP メソッド

- GET: データの取得
- POST: データの作成
- PUT: データの更新
- DELETE: データの削除

### レスポンス形式

- Content-Type: `application/json`
- 文字エンコーディング: UTF-8

### エラーレスポンス

エラーが発生した場合、以下の形式でレスポンスを返却します：

```json
{
  "error": {
    "code": "EC001",
    "message": "エラーメッセージ",
    "details": "詳細な情報（オプション）"
  }
}
```

### エラーコード一覧

| コード | HTTP ステータス | 説明                       |
| ------ | --------------- | -------------------------- |
| EC001  | 400             | リクエストパラメータエラー |
| EC002  | 404             | リソースが見つからない     |
| EC003  | 500             | 内部サーバーエラー         |

## エンドポイント一覧

### 1. ヘルスチェック

- **エンドポイント**: `GET /api/health`
- **概要**: API サーバーの稼働状況を確認

#### レスポンス例

```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### 2. カテゴリ一覧取得

- **エンドポイント**: `GET /api/categories`
- **概要**: 利用可能な学習カテゴリの一覧を取得

#### レスポンス例

```json
[
  {
    "id": "flags",
    "name": "国旗",
    "description": "世界各国の国旗を学習",
    "thumbnail": "https://cdn.example.com/thumbnails/flags.jpg"
  },
  {
    "id": "animals",
    "name": "動物",
    "description": "様々な動物を学習",
    "thumbnail": "https://cdn.example.com/thumbnails/animals.jpg"
  },
  {
    "id": "words",
    "name": "言葉",
    "description": "基本的な単語を学習",
    "thumbnail": "https://cdn.example.com/thumbnails/words.jpg"
  }
]
```

### 3. クイズ問題取得

- **エンドポイント**: `GET /api/quiz`
- **概要**: 指定されたカテゴリのクイズ問題を取得

#### クエリパラメータ

| パラメータ | 型     | 必須 | 説明                                       |
| ---------- | ------ | ---- | ------------------------------------------ |
| category   | string | Yes  | カテゴリ ID（flags, animals, words）       |
| count      | int    | No   | 取得する問題数（デフォルト: 10, 最大: 50） |

#### リクエスト例

```
GET /api/quiz?category=flags&count=5
```

#### レスポンス例

```json
[
  {
    "id": "quiz_flag_001",
    "questionImageUrl": "https://cdn.example.com/flags/italy.svg",
    "questionAudioUrl": "https://cdn.example.com/audio/italy.mp3",
    "correctAnswer": "イタリア",
    "choices": ["イタリア", "フランス", "ドイツ", "スペイン"],
    "category": "flags",
    "explanation": "イタリアの国旗は緑、白、赤の三色旗です。"
  },
  {
    "id": "quiz_flag_002",
    "questionImageUrl": "https://cdn.example.com/flags/france.svg",
    "questionAudioUrl": "https://cdn.example.com/audio/france.mp3",
    "correctAnswer": "フランス",
    "choices": ["イタリア", "フランス", "ドイツ", "スペイン"],
    "category": "flags",
    "explanation": "フランスの国旗は青、白、赤の三色旗です。"
  }
]
```

#### エラーレスポンス例

```json
{
  "error": {
    "code": "EC001",
    "message": "無効なカテゴリが指定されました",
    "details": "category: 'invalid_category' is not supported"
  }
}
```

### 4. 個別クイズ問題取得

- **エンドポイント**: `GET /api/quiz/{id}`
- **概要**: 指定された ID の個別クイズ問題を取得

#### パスパラメータ

| パラメータ | 型     | 必須 | 説明      |
| ---------- | ------ | ---- | --------- |
| id         | string | Yes  | クイズ ID |

#### レスポンス例

```json
{
  "id": "quiz_flag_001",
  "questionImageUrl": "https://cdn.example.com/flags/italy.svg",
  "questionAudioUrl": "https://cdn.example.com/audio/italy.mp3",
  "correctAnswer": "イタリア",
  "choices": ["イタリア", "フランス", "ドイツ", "スペイン"],
  "category": "flags",
  "explanation": "イタリアの国旗は緑、白、赤の三色旗です。",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

## データベース設計

### DynamoDB テーブル構成

#### テーブル名: `Quiz`

| 属性名           | 型     | 説明                                       |
| ---------------- | ------ | ------------------------------------------ |
| PK               | String | パーティションキー（例: `CATEGORY#flags`） |
| SK               | String | ソートキー（例: `QUIZ#quiz_flag_001`）     |
| id               | String | クイズ ID                                  |
| questionImageUrl | String | 問題画像 URL                               |
| questionAudioUrl | String | 問題音声 URL                               |
| correctAnswer    | String | 正解の選択肢                               |
| choices          | List   | 選択肢のリスト                             |
| category         | String | カテゴリ                                   |
| explanation      | String | 解説（オプション）                         |
| createdAt        | String | 作成日時（ISO 8601 形式）                  |
| updatedAt        | String | 更新日時（ISO 8601 形式）                  |

#### インデックス

- **GSI1**: category-id-index
  - パーティションキー: category
  - ソートキー: id

## 認証・認可

現在の仕様では認証機能は実装しません。
将来的に認証機能を追加する場合は、JWT（JSON Web Token）を使用した認証方式を予定しています。

## レート制限

- 1 分間あたり最大 100 リクエスト
- 超過した場合、HTTP ステータス 429（Too Many Requests）を返却

## CORS 設定

フロントエンドからのアクセスを許可するため、以下の CORS 設定を適用します：

- `Access-Control-Allow-Origin`: フロントエンドのドメイン
- `Access-Control-Allow-Methods`: GET, POST, PUT, DELETE, OPTIONS
- `Access-Control-Allow-Headers`: Content-Type, Authorization

## 開発・テスト環境での注意事項

### DynamoDB Local

- エンドポイント: `http://localhost:8000`
- テーブル作成スクリプトは `scripts/create-tables.sh` を参照

### モックデータ

- 開発環境では、初期データとして各カテゴリのサンプルクイズデータを投入
- データ投入スクリプトは `scripts/seed-quiz-data.sh` を参照
- 各カテゴリにつき 4 つの選択肢を持つクイズ問題を用意

## 今後の拡張予定

### v2.0 での追加予定機能

1. **ユーザー管理機能**

   - ユーザー登録・ログイン
   - 学習履歴の保存

2. **学習進捗管理**

   - クイズの正答率の記録
   - 回答履歴の統計

3. **クイズ管理機能**

   - クイズ問題の追加・更新・削除
   - 管理者向け API

4. **検索機能**
   - キーワード検索
   - フィルタリング機能

---

この API 仕様書は、プロジェクトの進行に合わせて更新されます。
最新版は常にこのドキュメントを参照してください。
