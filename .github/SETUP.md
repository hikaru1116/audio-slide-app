# GitHub Actions CI/CD セットアップ手順書

## 概要

Audio Slide App の GitHub Actions による CI/CD 環境のセットアップ手順を説明します。

- **CI**: develop ブランチでバックエンドテスト実行
- **CD**: main ブランチで ECS デプロイ実行
- **イメージタグ**: コミットハッシュを使用

## 前提条件

- AWS インフラが `terraform apply` で作成済み
- GitHub リポジトリが作成済み
- AWS CLI 設定済み

## 1. AWS 認証情報の準備

### 1.1 IAM ユーザー作成

GitHub Actions 用の IAM ユーザーを作成します：

```bash
# IAMユーザー作成
aws iam create-user --user-name github-actions-audio-slide-app

# プログラムアクセス用アクセスキー作成
aws iam create-access-key --user-name github-actions-audio-slide-app
```

**重要**: 出力された `AccessKeyId` と `SecretAccessKey` をメモしてください。

### 1.2 IAM ポリシー作成

GitHub Actions 用の権限ポリシーを作成します：

```bash
# ポリシーファイル作成
cat > github-actions-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeTaskDefinition",
                "ecs:RegisterTaskDefinition",
                "ecs:UpdateService",
                "ecs:DescribeServices"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::*:role/ecsTaskExecutionRole",
                "arn:aws:iam::*:role/ecsTaskRole"
            ]
        }
    ]
}
EOF

# IAMポリシー作成
aws iam create-policy \
    --policy-name GitHubActionsAudioSlidePolicy \
    --policy-document file://github-actions-policy.json

# ユーザーにポリシーアタッチ
aws iam attach-user-policy \
    --user-name github-actions-audio-slide-app \
    --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/GitHubActionsAudioSlidePolicy
```

## 2. GitHub Secrets 設定

GitHub リポジトリで Secrets 設定を行います：

### 2.1 リポジトリの Secrets 設定

1. GitHub リポジトリページにアクセス
2. **Settings** → **Secrets and variables** → **Actions** をクリック
3. **New repository secret** をクリックして以下を追加：

| Secret 名               | 値                                  | 説明                       |
| ----------------------- | ----------------------------------- | -------------------------- |
| `AWS_ACCESS_KEY_ID`     | 手順 1.1 で取得した AccessKeyId     | GitHub Actions 用 AWS 認証 |
| `AWS_SECRET_ACCESS_KEY` | 手順 1.1 で取得した SecretAccessKey | GitHub Actions 用 AWS 認証 |

### 2.2 設定確認

Secrets が正しく設定されているか確認：

```
✅ AWS_ACCESS_KEY_ID
✅ AWS_SECRET_ACCESS_KEY
```

## 3. ブランチ戦略設定

### 3.1 ブランチ保護ルール設定

1. GitHub リポジトリページで **Settings** → **Branches** をクリック
2. **Add rule** をクリック
3. 以下を設定：

**develop ブランチ用:**

- Branch name pattern: `develop`
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- Status checks: `backend-test` を選択

**main ブランチ用:**

- Branch name pattern: `main`
- ✅ Require status checks to pass before merging
- ✅ Require pull request reviews before merging
- ✅ Restrict pushes that create files to this branch

### 3.2 ブランチ作成

```bash
# developブランチ作成
git checkout -b develop
git push -u origin develop

# mainブランチ保護（既存の場合）
git checkout main
```

## 4. ワークフロー動作確認

### 4.1 CI 動作確認（develop ブランチ）

1. `app/backend` に変更を加える
2. develop ブランチにプッシュまたは PR 作成
3. GitHub Actions タブで CI Workflow の実行を確認

```bash
# テスト用変更例
cd app/backend
echo "// Test change" >> main.go
git add .
git commit -m "test: CI trigger test"
git push origin develop
```

### 4.2 CD 動作確認（main ブランチ）

1. develop から main への PR を作成
2. PR をマージ
3. GitHub Actions タブで CD Workflow の実行を確認
4. AWS ECS コンソールでデプロイ状況を確認

## 5. トラブルシューティング

### 5.1 よくあるエラー

**ECR 認証エラー:**

```
Error: Cannot perform an interactive login from a non TTY device
```

→ `AWS_ACCESS_KEY_ID` と `AWS_SECRET_ACCESS_KEY` の設定確認

**ECS 権限エラー:**

```
Error: User is not authorized to perform: ecs:UpdateService
```

→ IAM ポリシーの権限確認

**イメージプッシュエラー:**

```
Error: denied: Your authorization token has expired
```

→ ECR 認証の有効期限切れ、ワークフロー再実行

### 5.2 ログ確認方法

1. GitHub Actions タブでワークフロー実行をクリック
2. 失敗したジョブをクリック
3. エラーログを確認
4. AWS CloudWatch Logs でアプリケーションログも確認

### 5.3 手動デプロイ（緊急時）

GitHub Actions が失敗した場合の手動デプロイ手順：

```bash
# ECRログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-northeast-1.amazonaws.com

# イメージビルド・プッシュ
cd app/backend
docker build --platform linux/arm64 -t $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-northeast-1.amazonaws.com/audio-slide-backend:manual .
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-northeast-1.amazonaws.com/audio-slide-backend:manual

# ECSサービス更新（手動）
aws ecs update-service \
    --cluster audio-slide-cluster \
    --service audio-slide-app-backend-service \
    --force-new-deployment
```

## 6. セキュリティ考慮事項

- ✅ IAM ユーザーは最小権限の原則で作成
- ✅ Secrets は GitHub Secrets で暗号化保存
- ✅ main ブランチは保護ルールで保護
- ✅ コミットハッシュベースのイメージタグで追跡可能
- ⚠️ 定期的なアクセスキーローテーション推奨

## 7. 監視・運用

### 7.1 デプロイ状況確認

```bash
# ECSサービス状況確認
aws ecs describe-services \
    --cluster audio-slide-cluster \
    --services audio-slide-app-backend-service audio-slide-app-frontend-service

# 実行中タスク確認
aws ecs list-tasks --cluster audio-slide-cluster
```

### 7.2 ログ確認

```bash
# CloudWatch Logs確認
aws logs describe-log-groups --log-group-name-prefix "/ecs/audio-slide"

# 最新ログストリーム確認
aws logs describe-log-streams \
    --log-group-name "/ecs/audio-slide-app-backend" \
    --order-by LastEventTime \
    --descending \
    --max-items 1
```

これで GitHub Actions CI/CD 環境のセットアップが完了です！
