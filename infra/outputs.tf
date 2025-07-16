# ==================================================
# Terraform出力値定義 - Audio Slide App
# ==================================================
# デプロイ後に必要な情報を出力
# アプリケーションURL、ECRリポジトリ、リソース情報等

# ==================================================
# アプリケーションアクセス情報
# ==================================================

# ALBのDNS名 - アプリケーションへのメインアクセスURL
output "alb_dns_name" {
  description = "Load BalancerのDNS名（アプリケーションアクセス用）"
  value       = aws_lb.main.dns_name
}

# ALBのZone ID（Route 53でカスタムドメイン設定時に使用）
output "alb_zone_id" {
  description = "Load BalancerのZone ID（DNS設定用）"
  value       = aws_lb.main.zone_id
}

# アプリケーションのメインURL
output "application_url" {
  description = "アプリケーションのメインURL"
  value       = "http://${aws_lb.main.dns_name}"
}

# APIヘルスチェックURL
output "health_check_url" {
  description = "APIヘルスチェック用URL（サーバー状態確認用）"
  value       = "http://${aws_lb.main.dns_name}/api/health"
}

# ==================================================
# デプロイメント関連情報
# ==================================================

# ECRリポジトリURL（Dockerイメージプッシュ用）
output "ecr_backend_repository_url" {
  description = "バックエンド用ECRリポジトリURL（Dockerイメージプッシュ用）"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "フロントエンド用ECRリポジトリURL（Dockerイメージプッシュ用）"
  value       = aws_ecr_repository.frontend.repository_url
}

# ==================================================
# ストレージ関連情報
# ==================================================

# S3バケット名
output "s3_bucket_name" {
  description = "静的アセット用S3バケット名（アセットアップロード用）"
  value       = aws_s3_bucket.assets.bucket
}

# S3バケットURL
output "s3_bucket_url" {
  description = "静的アセット用S3バケットURL（ブラウザアクセス用）"
  value       = "https://${aws_s3_bucket.assets.bucket}.s3.${var.aws_region}.amazonaws.com"
}

# ==================================================
# リソース識別情報
# ==================================================

# DynamoDBテーブル名
output "dynamodb_table_name" {
  description = "アプリケーションデータ用DynamoDBテーブル名"
  value       = aws_dynamodb_table.quiz.name
}

# ECSクラスター名
output "ecs_cluster_name" {
  description = "コンテナ実行用ECSクラスター名"
  value       = aws_ecs_cluster.main.name
}

# ==================================================
# ネットワーク関連情報
# ==================================================

# VPC ID
output "vpc_id" {
  description = "使用中のVPC ID（専用VPC）"
  value       = aws_vpc.main.id
}

# サブネット情報
output "public_subnet_ids" {
  description = "パブリックサブネットIDリスト（ALB配置用）"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "プライベートサブネットIDリスト（ECSタスク配置用）"
  value       = aws_subnet.private[*].id
}

# セキュリティグループID
output "alb_security_group_id" {
  description = "ALB用セキュリティグループID（ネットワーク設定用）"
  value       = aws_security_group.alb_sg.id
}

output "ecs_security_group_id" {
  description = "ECS用セキュリティグループID（ネットワーク設定用）"
  value       = aws_security_group.ecs_sg.id
}