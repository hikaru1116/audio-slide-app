# Audio Slide App - デプロイ手順書

## 概要

この手順書では、Audio Slide AppをGitHub ActionsとTerraformを使用してAWSにデプロイする手順を説明します。

## デプロイメントアーキテクチャ

```
GitHub Repository
├── develop branch → CI (テスト実行)
└── main branch    → CD (ECSデプロイ)
                      ↓
                 AWS ECS (Fargate)
                ├── Backend (Go/Gin)
                └── Frontend (React)
```

## 前提条件

- ✅ AWS アカウント準備済み
- ✅ Terraform インストール済み
- ✅ AWS CLI 設定済み
- ✅ Docker インストール済み
- ✅ GitHub リポジトリ作成済み

## 1. 初回デプロイ手順

### 1.1 Terraformバックエンド準備

```bash
# S3バケット作成（Terraform状態管理用）
aws s3api create-bucket \
    --bucket audio-slide-app-terraform-state \
    --region ap-northeast-1 \
    --create-bucket-configuration LocationConstraint=ap-northeast-1

# バージョニング有効化
aws s3api put-bucket-versioning \
    --bucket audio-slide-app-terraform-state \
    --versioning-configuration Status=Enabled

# DynamoDBテーブル作成（ロック用）
aws dynamodb create-table \
    --table-name audio-slide-app-terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --region ap-northeast-1
```

### 1.2 AWSインフラ作成

```bash
# プロジェクトルートディレクトリに移動
cd audio-slide-app

# Terraformディレクトリに移動
cd infra

# 変数ファイル作成
cp terraform.tfvars.example terraform.tfvars

# 必要に応じて terraform.tfvars を編集
nano terraform.tfvars

# Terraform初期化
terraform init

# インフラ作成プラン確認
terraform plan

# インフラ作成実行
terraform apply
```

**重要**: `terraform apply` 実行後、出力された情報をメモしてください：
- ALB DNS名
- ECRリポジトリURL
- S3バケット名

### 1.3 初回イメージプッシュ

```bash
# AWSアカウントID取得
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ECRログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com

# バックエンドイメージビルド・プッシュ
cd ../app/backend
docker build --platform linux/arm64 -t $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/audio-slide-backend:latest .
docker push $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/audio-slide-backend:latest

# フロントエンドイメージビルド・プッシュ
cd ../frontend

# 本番用環境変数設定
cat > .env.production << EOF
REACT_APP_API_BASE_URL=/api
EOF

docker build --platform linux/arm64 -t $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/audio-slide-frontend:latest .
docker push $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/audio-slide-frontend:latest
```

### 1.4 静的アセットアップロード

```bash
# アセットをS3にアップロード
cd ../../
aws s3 sync assets/ s3://audio-slide-app-assets/ --delete
```

### 1.5 GitHub Actions設定

1. `.github/SETUP.md` の手順に従ってGitHub Secretsを設定
2. ブランチ保護ルールを設定
3. 初回テストプッシュを実行

## 2. 開発・運用フロー

### 2.1 開発フロー

```bash
# 1. 機能開発
git checkout -b feature/new-feature
# コード変更
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature

# 2. developブランチへPR作成・マージ
# → CI (テスト) が自動実行

# 3. mainブランチへPR作成・マージ  
# → CD (デプロイ) が自動実行
```

### 2.2 デプロイ確認

```bash
# デプロイ状況確認
aws ecs describe-services \
    --cluster audio-slide-cluster \
    --services audio-slide-app-backend-service audio-slide-app-frontend-service \
    --query "services[].{Name:serviceName,Status:status,Running:runningCount,Desired:desiredCount}"

# アプリケーション動作確認
curl http://$(terraform output -raw alb_dns_name)/api/health

# ブラウザでアクセス
echo "Application URL: http://$(terraform output -raw alb_dns_name)"
```

## 3. ホットフィックス手順

緊急修正が必要な場合：

```bash
# 1. hotfixブランチ作成
git checkout main
git checkout -b hotfix/critical-fix

# 2. 修正実装
# コード修正

# 3. 直接mainにマージ
git add .
git commit -m "hotfix: critical bug fix"
git checkout main
git merge hotfix/critical-fix
git push origin main

# 4. 自動デプロイ実行確認
# GitHub Actionsでデプロイ進行を確認

# 5. developブランチにも反映
git checkout develop
git merge main
git push origin develop
```

## 4. ロールバック手順

問題のあるデプロイをロールバックする場合：

### 4.1 GitHub Actionsでロールバック

```bash
# 1. 正常な過去のコミットを特定
git log --oneline

# 2. 過去のコミットでタグ作成
git checkout <正常なコミットハッシュ>
git tag -a rollback-$(date +%Y%m%d-%H%M) -m "Rollback to stable version"
git push origin rollback-$(date +%Y%m%d-%H%M)

# 3. mainブランチを過去の状態に戻す
git checkout main
git reset --hard <正常なコミットハッシュ>
git push --force-with-lease origin main
```

### 4.2 手動ロールバック（緊急時）

```bash
# ECSサービスを前のタスク定義に戻す
aws ecs update-service \
    --cluster audio-slide-cluster \
    --service audio-slide-app-backend-service \
    --task-definition audio-slide-app-backend:前のリビジョン番号

# 例：リビジョン5に戻す場合
aws ecs update-service \
    --cluster audio-slide-cluster \
    --service audio-slide-app-backend-service \
    --task-definition audio-slide-app-backend:5
```

## 5. スケーリング

### 5.1 手動スケーリング

```bash
# バックエンドタスク数を3に増加
aws ecs update-service \
    --cluster audio-slide-cluster \
    --service audio-slide-app-backend-service \
    --desired-count 3

# フロントエンドタスク数を2に増加  
aws ecs update-service \
    --cluster audio-slide-cluster \
    --service audio-slide-app-frontend-service \
    --desired-count 2
```

### 5.2 Terraformでのスケーリング

```bash
# terraform.tfvars編集
nano terraform.tfvars

# desired_countを変更
backend_desired_count  = 3
frontend_desired_count = 2

# 適用
terraform plan
terraform apply
```

## 6. 監視・ログ

### 6.1 アプリケーションログ確認

```bash
# 最新ログストリーム確認
aws logs describe-log-streams \
    --log-group-name "/ecs/audio-slide-app-backend" \
    --order-by LastEventTime \
    --descending \
    --max-items 1

# ログ内容確認
aws logs get-log-events \
    --log-group-name "/ecs/audio-slide-app-backend" \
    --log-stream-name "ログストリーム名"
```

### 6.2 メトリクス確認

```bash
# ECSサービスメトリクス確認
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name CPUUtilization \
    --dimensions Name=ServiceName,Value=audio-slide-app-backend-service Name=ClusterName,Value=audio-slide-cluster \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average
```

## 7. 環境削除

プロジェクト終了時のクリーンアップ：

```bash
# 1. ECSサービス削除
aws ecs update-service --cluster audio-slide-cluster --service audio-slide-app-backend-service --desired-count 0
aws ecs update-service --cluster audio-slide-cluster --service audio-slide-app-frontend-service --desired-count 0

# 2. Terraformでインフラ削除
cd infra
terraform destroy

# 3. ECRイメージ削除
aws ecr list-images --repository-name audio-slide-backend --query 'imageIds[*]' --output json | \
aws ecr batch-delete-image --repository-name audio-slide-backend --image-ids file:///dev/stdin

aws ecr list-images --repository-name audio-slide-frontend --query 'imageIds[*]' --output json | \
aws ecr batch-delete-image --repository-name audio-slide-frontend --image-ids file:///dev/stdin

# 4. S3バケット削除
aws s3 rm s3://audio-slide-app-assets --recursive
aws s3 rm s3://audio-slide-app-terraform-state --recursive
aws s3api delete-bucket --bucket audio-slide-app-assets
aws s3api delete-bucket --bucket audio-slide-app-terraform-state

# 5. DynamoDBテーブル削除
aws dynamodb delete-table --table-name audio-slide-app-terraform-locks
```

## 8. トラブルシューティング

### よくある問題と解決方法

**デプロイ失敗:**
```bash
# ECSタスクが停止する場合
aws ecs describe-tasks --cluster audio-slide-cluster --tasks $(aws ecs list-tasks --cluster audio-slide-cluster --query 'taskArns[0]' --output text)
```

**パフォーマンス問題:**
```bash
# CPU/メモリ使用率確認
aws ecs describe-services --cluster audio-slide-cluster --services audio-slide-app-backend-service
```

**ネットワーク問題:**
```bash
# セキュリティグループ確認
aws ec2 describe-security-groups --filters Name=group-name,Values=audio-slide-app-*
```

以上でAudio Slide Appのデプロイ手順は完了です！