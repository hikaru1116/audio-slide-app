# Audio Slide App AWS デプロイ手順書

## 前提条件

- AWS CLI インストール済み
- AWS 認証設定済み (`aws configure`)
- Docker インストール済み
- 適切な AWS IAM 権限（ECS、ECR、DynamoDB、S3、ALB、Route53）

## 環境変数設定

```bash
# 基本設定
export AWS_REGION="ap-northeast-1"
export PROJECT_NAME="audio-slide-app"
export CLUSTER_NAME="audio-slide-cluster"
export ECR_BACKEND_REPO="audio-slide-backend"
export ECR_FRONTEND_REPO="audio-slide-frontend"
export S3_BUCKET_NAME="audio-slide-app"
export DYNAMODB_TABLE_NAME="Quiz"

export APP_VERSION="0.5"

# AWS アカウント ID を取得
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

## 1. DynamoDB テーブル作成

```bash
# Quiz テーブル作成
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE_NAME \
    --attribute-definitions \
        AttributeName=PK,AttributeType=S \
        AttributeName=SK,AttributeType=S \
        AttributeName=category,AttributeType=S \
        AttributeName=id,AttributeType=S \
    --key-schema \
        AttributeName=PK,KeyType=HASH \
        AttributeName=SK,KeyType=RANGE \
    --global-secondary-indexes \
        'IndexName=category-id-index,KeySchema=[{AttributeName=category,KeyType=HASH},{AttributeName=id,KeyType=RANGE}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}' \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $AWS_REGION

# テーブル作成完了まで待機
aws dynamodb wait table-exists --table-name $DYNAMODB_TABLE_NAME --region $AWS_REGION
echo "DynamoDB テーブル作成完了"
```

## 2. S3 バケット作成

```bash
# S3 バケット作成
aws s3api create-bucket \
    --bucket $S3_BUCKET_NAME \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION

# パブリック読み取りアクセス設定
aws s3api put-bucket-policy \
    --bucket $S3_BUCKET_NAME \
    --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::'$S3_BUCKET_NAME'/*"
            }
        ]
    }'

echo "S3 バケット作成完了: $S3_BUCKET_NAME"
```

## 3. 静的ファイル（画像・音声）のアップロード

```bash
# assets フォルダを S3 にアップロード
aws s3 sync ../assets/ s3://$S3_BUCKET_NAME/ --delete

echo "静的ファイルアップロード完了"
```

## 4. ECR リポジトリ作成

```bash
# バックエンド用 ECR リポジトリ
aws ecr create-repository \
    --repository-name $ECR_BACKEND_REPO \
    --region $AWS_REGION

# フロントエンド用 ECR リポジトリ
aws ecr create-repository \
    --repository-name $ECR_FRONTEND_REPO \
    --region $AWS_REGION

echo "ECR リポジトリ作成完了"
```

## 5. Docker イメージビルド・プッシュ

### バックエンド

```bash
# ECR ログイン
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# バックエンドイメージビルド
cd backend
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND_REPO:$APP_VERSION .

# タグ付け
# docker tag $ECR_BACKEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND_REPO:latest

# プッシュ
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND_REPO:$APP_VERSION

cd ..
echo "バックエンドイメージプッシュ完了"
```

### フロントエンド

```bash
# フロントエンドイメージビルド（API エンドポイント設定）
cd frontend

# 環境変数設定ファイル作成
cat > .env.production << EOF
REACT_APP_API_BASE_URL=http://audio-slide-alb-76204901.ap-northeast-1.elb.amazonaws.com/
EOF

docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND_REPO:$APP_VERSION .

# タグ付け
# docker tag $ECR_FRONTEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND_REPO:latest

# プッシュ
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND_REPO:$APP_VERSION

cd ..
echo "フロントエンドイメージプッシュ完了"
```

## 6. ECS クラスター作成

```bash
# ECS クラスター作成
aws ecs create-cluster \
    --cluster-name $CLUSTER_NAME \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1 \
    --region $AWS_REGION

echo "ECS クラスター作成完了"
```

## 7. IAM ロール作成

### タスク実行ロール

```bash
# タスク実行ロール作成
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

# ポリシーアタッチ
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### タスクロール

```bash
# タスクロール作成
aws iam create-role \
    --role-name ecsTaskRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

# DynamoDB アクセス用ポリシー作成
aws iam create-policy \
    --policy-name AudioSlideDynamoDBPolicy \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:Query",
                    "dynamodb:Scan",
                    "dynamodb:UpdateItem",
                    "dynamodb:DeleteItem"
                ],
                "Resource": "arn:aws:dynamodb:'$AWS_REGION':'$AWS_ACCOUNT_ID':table/'$DYNAMODB_TABLE_NAME'*"
            }
        ]
    }'

# ポリシーアタッチ
aws iam attach-role-policy \
    --role-name ecsTaskRole \
    --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/AudioSlideDynamoDBPolicy

echo "IAM ロール作成完了"
```

## 8. VPC とセキュリティグループ設定

```bash
# デフォルト VPC ID 取得
export VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)

# サブネット ID 取得
export SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text | tr '\t' ',')

# セキュリティグループ作成（ALB 用）
export ALB_SG_ID=$(aws ec2 create-security-group \
    --group-name audio-slide-alb-sg \
    --description "Security group for Audio Slide ALB" \
    --vpc-id $VPC_ID \
    --query "GroupId" --output text)

# ALB セキュリティグループルール追加
aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# セキュリティグループ作成（ECS 用）
export ECS_SG_ID=$(aws ec2 create-security-group \
    --group-name audio-slide-ecs-sg \
    --description "Security group for Audio Slide ECS" \
    --vpc-id $VPC_ID \
    --query "GroupId" --output text)

# ECS セキュリティグループルール追加
aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG_ID \
    --protocol tcp \
    --port 8080 \
    --source-group $ALB_SG_ID

aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG_ID \
    --protocol tcp \
    --port 80 \
    --source-group $ALB_SG_ID

echo "セキュリティグループ作成完了"
```

## 9. Application Load Balancer 作成

```bash
# ALB 作成
export ALB_ARN=$(aws elbv2 create-load-balancer \
    --name audio-slide-alb \
    --subnets $(echo $SUBNET_IDS | tr ',' ' ') \
    --security-groups $ALB_SG_ID \
    --query "LoadBalancers[0].LoadBalancerArn" --output text)

# ターゲットグループ作成（フロントエンド用）
export FRONTEND_TG_ARN=$(aws elbv2 create-target-group \
    --name audio-slide-frontend-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path "/" \
    --query "TargetGroups[0].TargetGroupArn" --output text)

# ターゲットグループ作成（バックエンド用）
export BACKEND_TG_ARN=$(aws elbv2 create-target-group \
    --name audio-slide-backend-tg \
    --protocol HTTP \
    --port 8080 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path "/api/health" \
    --query "TargetGroups[0].TargetGroupArn" --output text)

# リスナー作成
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$FRONTEND_TG_ARN

# リスナールール作成（API パス用）
export LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --query "Listeners[0].ListenerArn" --output text)

aws elbv2 create-rule \
    --listener-arn $LISTENER_ARN \
    --priority 100 \
    --conditions Field=path-pattern,Values="/api/*" \
    --actions Type=forward,TargetGroupArn=$BACKEND_TG_ARN

echo "Application Load Balancer 作成完了"
```

## 10. Task Definition 作成

### バックエンド Task Definition

```bash
cat > backend-task-definition.template.json <<EOF
{
    "family": "audio-slide-backend",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "runtimePlatform": {
        "cpuArchitecture": "ARM64",
        "operatingSystemFamily": "LINUX"
    },
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::\$AWS_ACCOUNT_ID:role/ecsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::\$AWS_ACCOUNT_ID:role/ecsTaskRole",
    "containerDefinitions": [
        {
            "name": "audio-slide-backend",
            "image": "\$AWS_ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$ECR_BACKEND_REPO:\$APP_VERSION",
            "portMappings": [
                {
                    "containerPort": 8080,
                    "protocol": "tcp"
                }
            ],
            "environment": [
                { "name": "AWS_REGION", "value": "\$AWS_REGION" },
                { "name": "PORT", "value": "8080" },
                { "name": "S3_BUCKET_NAME", "value": "\$S3_BUCKET_NAME" },
                { "name": "S3_REGION", "value": "\$AWS_REGION" }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/audio-slide-backend",
                    "awslogs-region": "\$AWS_REGION",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ]
}
EOF

envsubst < backend-task-definition.template.json > backend-task-definition.json

# ログ グループ作成
aws logs create-log-group --log-group-name /ecs/audio-slide-backend --region $AWS_REGION

# Task Definition 登録
aws ecs register-task-definition --cli-input-json file://backend-task-definition.json
```

### フロントエンド Task Definition

```bash
cat > frontend-task-definition.template.json <<EOF
{
    "family": "audio-slide-frontend",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "runtimePlatform": {
        "cpuArchitecture": "ARM64",
        "operatingSystemFamily": "LINUX"
    },
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::\$AWS_ACCOUNT_ID:role/ecsTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "audio-slide-frontend",
            "image": "\$AWS_ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$ECR_FRONTEND_REPO:\$APP_VERSION",
            "portMappings": [
                {
                    "containerPort": 80,
                    "protocol": "tcp"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/audio-slide-frontend",
                    "awslogs-region": "\$AWS_REGION",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ]
}
EOF

envsubst < frontend-task-definition.template.json > frontend-task-definition.json


# ログ グループ作成
aws logs create-log-group --log-group-name /ecs/audio-slide-frontend --region $AWS_REGION

# Task Definition 登録
aws ecs register-task-definition --cli-input-json file://frontend-task-definition.json

echo "Task Definition 作成完了"
```

## 11. ECS サービス作成

### バックエンドサービス

```bash
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name audio-slide-backend-service \
    --task-definition audio-slide-backend \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$(echo $SUBNET_IDS)],securityGroups=[$ECS_SG_ID],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=$BACKEND_TG_ARN,containerName=audio-slide-backend,containerPort=8080"
```

```bash
# サービスを更新（最新のTask Definitionを使用）
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service audio-slide-backend-service \
    --task-definition audio-slide-backend

# 更新完了を待機
aws ecs wait services-stable \
    --cluster $CLUSTER_NAME \
    --services audio-slide-backend-service

echo "バックエンドサービス更新完了"
```

### フロントエンドサービス

```bash
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name audio-slide-frontend-service \
    --task-definition audio-slide-frontend \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$(echo $SUBNET_IDS)],securityGroups=[$ECS_SG_ID],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=$FRONTEND_TG_ARN,containerName=audio-slide-frontend,containerPort=80"

echo "ECS サービス作成完了"
```

```bash
# サービスを更新（最新のTask Definitionを使用）
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service audio-slide-frontend-service \
    --task-definition audio-slide-frontend

# 更新完了を待機
aws ecs wait services-stable \
    --cluster $CLUSTER_NAME \
    --services audio-slide-frontend-service

echo "フロントエンドサービス更新完了"
```

## 12. 動作確認

```bash
# ALB の DNS 名取得
export ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN --query "LoadBalancers[0].DNSName" --output text)

echo "アプリケーション URL: http://$ALB_DNS"
echo "ヘルスチェック URL: http://$ALB_DNS/api/health"

# サービス状態確認
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services audio-slide-backend-service audio-slide-frontend-service \
    --query "services[].{Name:serviceName,Status:status,Running:runningCount,Desired:desiredCount}"
```

## 13. 初期データ投入（必要に応じて）

```bash
# DynamoDB にサンプルデータを投入
# app/scripts/seed-data.sh を実行する場合：
cd app/scripts
chmod +x seed-data.sh
./seed-data.sh
```

## 14. クリーンアップ（削除時）

```bash
# ECS サービス削除
aws ecs update-service --cluster $CLUSTER_NAME --service audio-slide-backend-service --desired-count 0
aws ecs update-service --cluster $CLUSTER_NAME --service audio-slide-frontend-service --desired-count 0
aws ecs delete-service --cluster $CLUSTER_NAME --service audio-slide-backend-service
aws ecs delete-service --cluster $CLUSTER_NAME --service audio-slide-frontend-service

# クラスター削除
aws ecs delete-cluster --cluster $CLUSTER_NAME

# ALB とターゲットグループ削除
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
aws elbv2 delete-target-group --target-group-arn $FRONTEND_TG_ARN
aws elbv2 delete-target-group --target-group-arn $BACKEND_TG_ARN

# S3 バケット削除
aws s3 rm s3://$S3_BUCKET_NAME --recursive
aws s3api delete-bucket --bucket $S3_BUCKET_NAME

# DynamoDB テーブル削除
aws dynamodb delete-table --table-name $DYNAMODB_TABLE_NAME

# ECR リポジトリ削除
aws ecr delete-repository --repository-name $ECR_BACKEND_REPO --force
aws ecr delete-repository --repository-name $ECR_FRONTEND_REPO --force
```

## 注意事項

1. **料金**: ECS Fargate、ALB、DynamoDB 等の利用料金が発生します
2. **セキュリティ**: 本手順書は検証用です。本番環境では適切なセキュリティ設定を行ってください
3. **SSL**: 必要に応じて ACM で SSL 証明書を取得し、HTTPS リスナーを追加してください
4. **ドメイン**: Route 53 でカスタムドメインを設定する場合は、別途設定が必要です
5. **モニタリング**: CloudWatch でログとメトリクスを監視することをお勧めします

## トラブルシューティング

- **サービスが起動しない**: ECS コンソールでタスクのログを確認
- **ALB ヘルスチェック失敗**: セキュリティグループとヘルスチェックパスを確認
- **API 呼び出しエラー**: バックエンドのログと DynamoDB 権限を確認
