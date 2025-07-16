# Audio Slide App - Terraform Infrastructure

このディレクトリには、Audio Slide App の AWS インフラストラクチャを Terraform で管理するためのコードが含まれています。

## 構成

### ファイル構成

- `backend.tf` - Terraform バックエンド設定（S3 + DynamoDB）
- `variables.tf` - 変数定義
- `terraform.tfvars.example` - 変数の設定例
- `network.tf` - VPC、セキュリティグループ
- `iam.tf` - IAM ロール、ポリシー
- `ecr.tf` - ECR リポジトリ
- `s3.tf` - S3 バケット（静的ファイル用）
- `dynamodb.tf` - DynamoDB テーブル
- `cloudwatch.tf` - CloudWatch ログ
- `loadbalancer.tf` - Application Load Balancer
- `ecs.tf` - ECS クラスター、タスク定義、サービス
- `outputs.tf` - 出力値定義

### 作成される AWS リソース

- **ECS Cluster** - Fargate でアプリケーションを実行
- **ECR Repository** - バックエンド・フロントエンド用 Docker イメージ
- **DynamoDB Table** - アプリケーションデータ（Quiz）
- **S3 Bucket** - 静的ファイル（画像・音声）
- **Application Load Balancer** - トラフィック分散
- **IAM Roles** - ECS タスクの実行権限
- **CloudWatch Logs** - アプリケーションログ
- **Security Groups** - ネットワークセキュリティ

## デプロイ手順

### 1. 前提条件

- AWS CLI 設定済み
- Terraform 1.0 以上インストール済み
- 適切な AWS 権限

### 2. 初期設定

```bash
# terraformディレクトリに移動
cd infra

# 変数ファイルを作成
cp terraform.tfvars.example terraform.tfvars

# 必要に応じて terraform.tfvars を編集
```

### 3. Terraform バックエンド用リソースの手動作成

Terraform の状態管理用の S3 バケットと DynamoDB テーブルを事前に作成する必要があります：

```bash
# S3バケット作成
aws s3api create-bucket \
    --bucket audio-slide-app-terraform-state \
    --region ap-northeast-1 \
    --create-bucket-configuration LocationConstraint=ap-northeast-1

# バケットバージョニング有効化
aws s3api put-bucket-versioning \
    --bucket audio-slide-app-terraform-state \
    --versioning-configuration Status=Enabled
```

### 4. Terraform 実行

```bash
# 初期化
terraform init

# プランの確認
terraform plan

# 適用
terraform apply
```

### 5. 出力値確認

デプロイ完了後、以下のコマンドで重要な情報を確認できます：

```bash
# アプリケーションURL
terraform output application_url

# ECRリポジトリURL
terraform output ecr_backend_repository_url
terraform output ecr_frontend_repository_url

# S3バケット名
terraform output s3_bucket_name
```

## アプリケーションデプロイ

インフラ作成後、以下の手順でアプリケーションをデプロイします：

### 1. ECR にログイン

```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $(terraform output -raw ecr_backend_repository_url | cut -d'/' -f1)
```

### 2. Docker イメージビルド・プッシュ

```bash
# バックエンド
cd ../app/backend
docker build --platform linux/arm64 -t $(terraform output -raw ecr_backend_repository_url):0.5 .
docker push $(terraform output -raw ecr_backend_repository_url):0.5

# フロントエンド
cd ../frontend
docker build --platform linux/arm64 -t $(terraform output -raw ecr_frontend_repository_url):0.5 .
docker push $(terraform output -raw ecr_frontend_repository_url):0.5
```

### 3. 静的ファイルアップロード

```bash
# assetsフォルダをS3にアップロード
cd ../../
aws s3 sync assets/ s3://$(terraform output -raw s3_bucket_name)/ --delete
```

### 4. ECS サービス更新

```bash
# サービスを最新のタスク定義で更新
aws ecs update-service \
    --cluster $(terraform output -raw ecs_cluster_name) \
    --service audio-slide-app-backend-service \
    --force-new-deployment

aws ecs update-service \
    --cluster $(terraform output -raw ecs_cluster_name) \
    --service audio-slide-app-frontend-service \
    --force-new-deployment
```

## 動作確認

```bash
# アプリケーションURL
echo "Application: $(terraform output -raw application_url)"

# API健康チェック
curl $(terraform output -raw health_check_url)
```

## クリーンアップ

```bash
# Terraformで作成したリソースを削除
terraform destroy

# 手動で作成したバックエンドリソースも削除
aws s3 rm s3://audio-slide-app-terraform-state --recursive
aws s3api delete-bucket --bucket audio-slide-app-terraform-state
aws dynamodb delete-table --table-name audio-slide-app-terraform-locks
```

## 注意事項

- ARM64 アーキテクチャを使用（Graviton2 プロセッサ）
- デフォルト VPC を使用
- S3 バケットはパブリック読み取りアクセス許可
- CloudWatch ログの保持期間は 14 日
- ECR イメージライフサイクルポリシーで最新 10 個のイメージを保持
