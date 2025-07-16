# 音声スライド学習アプリ - 開発環境

## 概要

このディレクトリには、音声スライド学習アプリの開発環境が含まれています。
Docker Composeを使用して、バックエンドAPI、DynamoDB Local、および必要な初期データセットアップを自動化しています。

## 前提条件

- Docker Desktop がインストールされていること
- Docker Compose がインストールされていること（通常Docker Desktopに含まれています）

## クイックスタート

### 1. 環境の起動

```bash
# アプリケーションディレクトリに移動
cd app

# 全サービスをバックグラウンドで起動
docker-compose up -d

# ログを確認（オプション）
docker-compose logs -f
```

### 2. DynamoDBテーブル作成（手動）

```bash
# DynamoDBテーブルを作成
docker run --rm --network app_audio-slide-network \
  -e AWS_ACCESS_KEY_ID=dummy \
  -e AWS_SECRET_ACCESS_KEY=dummy \
  -e AWS_DEFAULT_REGION=ap-northeast-1 \
  amazon/aws-cli:latest \
  dynamodb create-table \
  --endpoint-url http://dynamodb-local:8000 \
  --region ap-northeast-1 \
  --table-name Quiz \
  --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S \
  --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### 3. 動作確認

バックエンドAPIのヘルスチェック：
```bash
curl http://localhost:8080/api/health
```

フロントエンドアプリケーションへのアクセス：
```bash
# ブラウザで以下のURLにアクセス
http://localhost:3000
```

API動作確認：
```bash
# カテゴリ一覧の取得
curl http://localhost:8080/api/categories

# クイズ問題の取得
curl "http://localhost:8080/api/quiz?category=flags&count=3"
```

### 3. 環境の停止

```bash
# サービスを停止
docker-compose down

# データも含めて完全に削除（注意：データが失われます）
docker-compose down -v
```

## サービス構成

### フロントエンド (`frontend`)
- **ポート**: 3000
- **技術**: React 18 + Vite + TypeScript + Tailwind CSS
- **アクセス**: http://localhost:3000

### バックエンド API (`backend`)
- **ポート**: 8080
- **技術**: Go 1.21 + Gin Framework
- **エンドポイント**: 
  - `GET /api/health` - ヘルスチェック
  - `GET /api/categories` - カテゴリ一覧
  - `GET /api/quiz` - クイズ問題取得
  - `GET /api/quiz/{id}` - 個別クイズ取得

### DynamoDB Local (`dynamodb-local`)
- **ポート**: 8000
- **用途**: 開発環境用のDynamoDBエミュレータ
- **データ**: Dockerボリュームに永続化

### DynamoDB Admin (`dynamodb-admin`)
- **ポート**: 8002
- **用途**: DynamoDBのWeb管理画面
- **アクセス**: http://localhost:8002

### DynamoDB初期化 (`dynamodb-init`)
- **用途**: テーブル作成とサンプルデータ投入
- **実行**: 起動時に1回のみ実行される

## データ構成

### テーブル
- **テーブル名**: `Quiz`
- **パーティションキー**: `PK` (例: `CATEGORY#flags`)
- **ソートキー**: `SK` (例: `QUIZ#quiz_flag_001`)
- **GSI**: `category-id-index`

### サンプルデータ
初期データとして以下のクイズが投入されます：
- **国旗**: 5問（イタリア、フランス、日本、アメリカ、ブラジル）
- **動物**: 5問（ライオン、象、ペンギン、パンダ、カンガルー）
- **言葉**: 5問（りんご、本、車、家、水）

## トラブルシューティング

### ポートが使用中の場合
```bash
# 使用中のポートを確認
lsof -i :8080
lsof -i :8000

# 該当プロセスを終了してから再実行
```

### データをリセットしたい場合
```bash
# コンテナとボリュームを削除
docker-compose down -v

# 再度起動
docker-compose up -d
```

### ログの確認
```bash
# 全サービスのログ
docker-compose logs

# 特定サービスのログ
docker-compose logs backend
docker-compose logs dynamodb-local
```

## 開発モード

バックエンドのみを開発モードで実行する場合：

```bash
# DynamoDB Localのみ起動
docker-compose up -d dynamodb-local dynamodb-init

# バックエンドをローカルで実行
cd backend
go run ./cmd/api/main.go
```

## API仕様

詳細なAPI仕様は以下を参照してください：
- Markdown: `../spec/backend/api.md`
- OpenAPI: `../spec/backend/api.yaml`

## 環境変数

環境変数の設定例は `.env.example` を参照してください。