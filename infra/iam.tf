# ==================================================
# IAM設定 - Audio Slide App
# ==================================================
# ECSタスクの実行に必要なIAMロールとポリシーを定義
# - Task Execution Role: ECRからのイメージ取得、CloudWatchログ出力用
# - Task Role: アプリケーションがAWSサービスにアクセスするための権限

# ==================================================
# 現在のAWSアカウント情報を取得
# ==================================================
# リソースARNの構築に使用
data "aws_caller_identity" "current" {}

# ==================================================
# ECS Task Execution Role
# ==================================================
# ECSサービスがタスクを起動するために使用するロール
# - ECRからDockerイメージをプル
# - CloudWatch Logsにログを出力
# - ECSサービス自体が使用する権限

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"  # AWS標準のロール名を使用

  # 信頼ポリシーを外部JSONファイルから読み込み
  assume_role_policy = file("${path.module}/policies/ecs-task-execution-trust-policy.json")

  tags = {
    Name = "${var.project_name}-ecs-task-execution-role"
  }
}

# ECS Task Execution RoleにAWS管理ポリシーをアタッチ
# AWSが提供する標準ポリシーで、ECRやCloudWatch Logsへのアクセス権限を含む
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ==================================================
# ECS Task Role
# ==================================================
# アプリケーションコードが実行時に使用するロール
# - DynamoDBへのアクセス権限
# - S3へのアクセス権限（必要に応じて）
# - その他のAWSサービスへのアクセス権限

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"  # AWS標準のロール名を使用

  # 信頼ポリシーを外部JSONファイルから読み込み
  assume_role_policy = file("${path.module}/policies/ecs-task-trust-policy.json")

  tags = {
    Name = "${var.project_name}-ecs-task-role"
  }
}

# ==================================================
# DynamoDBアクセスポリシー
# ==================================================
# アプリケーションがDynamoDBテーブルにアクセスするための権限を定義
# クイズデータの読み取り、書き込み、更新、削除権限を含む

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "${var.project_name}-DynamoDBPolicy"
  description = "DynamoDB access policy for Audio Slide App"

  # 実際の権限定義（Permission Policy）
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # DynamoDBの基本操作権限
        Action = [
          "dynamodb:GetItem",    # アイテムの取得
          "dynamodb:PutItem",    # アイテムの作成
          "dynamodb:Query",      # クエリ検索
          "dynamodb:Scan",       # スキャン検索
          "dynamodb:UpdateItem", # アイテムの更新
          "dynamodb:DeleteItem", # アイテムの削除
          "dynamodb:BatchGetItem",    # バッチ取得
          "dynamodb:BatchWriteItem"   # バッチ書き込み
        ]
        # アクセス対象リソースを指定
        Resource = [
          # メインテーブルへのアクセス
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}",
          # GSI（Global Secondary Index）へのアクセス
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}/index/*"
        ]
      }
    ]
  })
}

# DynamoDBポリシーをECS Task Roleにアタッチ
# これによりアプリケーションがDynamoDBにアクセス可能になる
resource "aws_iam_role_policy_attachment" "ecs_task_role_dynamodb_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}