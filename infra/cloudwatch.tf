# ==================================================
# CloudWatch Logs設定 - Audio Slide App
# ==================================================
# ECSタスクから出力されるログを集中管理
# アプリケーションのデバッグ、監視、トラブルシューティングに使用

# ==================================================
# バックエンド用ロググループ
# ==================================================
# Go/Gin APIサーバーのログを集約
# リクエストログ、エラーログ、アプリケーションログ等

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.project_name}-backend"  # ECSロググループの標準命名規則
  retention_in_days = 14                                # ログ保存期間（14日間）

  tags = {
    Name = "${var.project_name}-backend-logs"
    Type = "application-logs"  # アプリケーションログであることを明示
  }
}

# ==================================================
# フロントエンド用ロググループ
# ==================================================
# React Webアプリケーションのログを集約
# Nginxアクセスログ、エラーログ等

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.project_name}-frontend"  # ECSロググループの標準命名規則
  retention_in_days = 14                                 # ログ保存期間（14日間）

  tags = {
    Name = "${var.project_name}-frontend-logs"
    Type = "web-server-logs"  # Webサーバーログであることを明示
  }
}