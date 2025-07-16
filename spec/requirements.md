# 音声スライド学習 Web アプリ 要件定義書（v1.7）

## 1. 概要

本アプリは、「国旗」「動物」「言葉」などのカテゴリに応じた学習を、**画像・テキスト・音声**で行える教育用 Web アプリです。  
バックエンドは **Go（Gin）**、フロントエンドは **React** を使用し、データベースには **Amazon DynamoDB** を採用します。  
実行環境は **AWS ECS（Fargate）**、ローカル開発は **docker-compose による DynamoDB Local** で行います。

---

## 2. 対応カテゴリ（拡張設計）

| カテゴリ | 表示内容の例                        |
| -------- | ----------------------------------- |
| 国旗     | 国旗画像・国名・国名読み上げ（MP3） |
| 動物     | 動物写真・名前・鳴き声（MP3）       |
| 言葉     | 単語・意味・発音（MP3）             |

---

## 3. 機能要件

### 3.1 カテゴリ選択画面

- 学習カテゴリ（国旗、動物、言葉）をユーザーが選択
- サムネイル画像付きカード UI で表示

### 3.2 学習スライド画面

- スライドに以下の要素を表示：
  - **画像**
  - **テキスト（国名など）**
  - **音声再生（MP3）**
- ユーザーはテキストの選択の中から、画像と一致するテキストを選択すると正誤が表示され、次のスライドへ移動する。
- 表示順はランダム

### 3.3 音声再生機能

- MP3 ファイルを `<audio>` タグまたは `Audio` オブジェクトで再生
- 自動再生＋手動再生の両方をサポート

---

## 4. 技術構成

### バックエンド（Go/Gin）

| 項目          | 内容                             |
| ------------- | -------------------------------- |
| 言語          | Go（v1.22+ 推奨）                |
| Web FW        | Gin                              |
| DB            | DynamoDB（本番）                 |
| ローカル用 DB | DynamoDB Local（docker-compose） |
| 静的ファイル  | S3 に格納した画像・音声ファイル  |

#### API 例：

````
GET /api/contents?category=flags&count=10
##### レスポンス例：

```json
[
  {
    "label": "イタリア",
    "imageUrl": "https://cdn.example.com/flags/italy.svg",
    "audioUrl": "https://cdn.example.com/audio/italy.mp3"
  }
]
````

### フロントエンド（React）

| 項目           | 内容                            |
| -------------- | ------------------------------- |
| 言語           | TypeScript（推奨）              |
| フレームワーク | React（Vite または CRA）        |
| UI             | Tailwind CSS または Material UI |
| 音声再生       | HTML `<audio>` タグ             |
| 通信           | Axios / Fetch API               |

---

### データベース（DynamoDB）

#### テーブル構成（例）

| 属性名     | 型     | 説明                             |
| ---------- | ------ | -------------------------------- |
| `PK`       | String | 例：`CATEGORY#flags`             |
| `SK`       | String | 例：`ITEM#france`                |
| `label`    | String | 表示名（国名、動物名など）       |
| `imageUrl` | String | S3 または CDN の URL             |
| `audioUrl` | String | S3 または CDN の URL（MP3 音声） |

---

## 5. インフラ構成（ECS + S3）

```
[ Route 53 ]
│
[ Application Load Balancer ]
│
[ AWS ECS (Fargate) ]
┌──────────────┬───────────────┐
│ │ │
▼ ▼ ▼
React Frontend Gin API Server CloudWatch Logs
│ │
▼ ▼
S3（画像・音声） DynamoDB（本番）
```

## 6. ローカル開発構成

### docker-compose.yml（DynamoDB Local）

```yaml
version: "3"
services:
  dynamodb-local:
    image: amazon/dynamodb-local
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - ./dynamodb-data:/home/dynamodblocal/data
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath /home/dynamodblocal/data"
```

## 7. CI/CD 概要

- GitHub Actions による自動ビルド・デプロイ
- バックエンド・フロントエンドをそれぞれコンテナ化し、Amazon ECR へ push
- ECS（Fargate）上のサービスが定義された Task Definition を更新
- 必要に応じて CloudFormation または Terraform による IaC 対応

## 8. 今後提供可能な設計資料（必要に応じて）

以下の設計資料は、プロジェクト進行状況やニーズに応じて随時提供・更新可能です。

| 資料名                     | 説明                                                                               |
| -------------------------- | ---------------------------------------------------------------------------------- |
| API 仕様書（OpenAPI 形式） | REST API エンドポイントの詳細、パラメータ、レスポンス定義などを含む Swagger 仕様書 |
| DynamoDB テーブル定義      | テーブル構造、PK/SK、属性一覧、カテゴリ別構成など                                  |
| React UI 構成テンプレート  | スライド UI・カテゴリ選択 UI などの基本 React 構成とコンポーネント設計             |
| 初期データ投入スクリプト   | DynamoDB 用のカテゴリ・国旗などの初期データ登録スクリプト（JSON/CLI）              |
