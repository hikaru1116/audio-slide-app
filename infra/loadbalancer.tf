# ==================================================
# Application Load Balancer設定 - Audio Slide App
# ==================================================
# インターネットからのトラフィックをフロントエンドとバックエンドに適切に分散
# - パスベースルーティングでAPIとWebを分離
# - ヘルスチェックによる自動フェイルオーバー
# - 複数AZでの高可用性

# ==================================================
# メインALB
# ==================================================
# アプリケーションへの入り口となるLoad Balancer

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"    # ALB名
  internal           = false                        # インターネット向け（external）
  load_balancer_type = "application"                # Application Load Balancer（L7）
  security_groups    = [aws_security_group.alb_sg.id]  # セキュリティグループをアタッチ
  subnets            = aws_subnet.public[*].id # 専用VPCのパブリックサブネットに配置

  enable_deletion_protection = false  # 開発環境では削除保護を無効化

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ==================================================
# ターゲットグループ設定
# ==================================================
# ALBがトラフィックを転送する先を定義
# ヘルスチェックでターゲットの正常性を監視

# フロントエンド用ターゲットグループ
# Reactアプリケーション（Nginxサービング）へのトラフィックを管理
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend-tg"  # ターゲットグループ名
  port        = 80                                # ターゲットポート（Nginx標準ポート）
  protocol    = "HTTP"                            # プロトコル
  vpc_id      = aws_vpc.main.id                   # 専用VPCを指定
  target_type = "ip"                              # IPアドレスベースのターゲット（Fargate用）

  # ヘルスチェック設定
  health_check {
    enabled             = true              # ヘルスチェック有効化
    healthy_threshold   = 2                 # 正常判定闾値（連続2回成功で正常）
    interval            = 30                # チェック間隔（30秒）
    matcher             = "200"             # 正常レスポンスコード
    path                = "/"               # ヘルスチェックパス（ルート）
    port                = "traffic-port"    # トラフィックポートと同じポートでチェック
    protocol            = "HTTP"            # チェックプロトコル
    timeout             = 5                 # タイムアウト（5秒）
    unhealthy_threshold = 2                 # 異常判定闾値（連続2回失敗で異常）
  }

  tags = {
    Name = "${var.project_name}-frontend-tg"
  }
}

# バックエンド用ターゲットグループ
# Go/Gin APIサーバーへのトラフィックを管理
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-backend-tg"   # ターゲットグループ名
  port        = 8080                              # ターゲットポート（Goアプリケーションポート）
  protocol    = "HTTP"                            # プロトコル
  vpc_id      = aws_vpc.main.id                   # 専用VPCを指定
  target_type = "ip"                              # IPアドレスベースのターゲット（Fargate用）

  # APIサーバー用ヘルスチェック設定
  health_check {
    enabled             = true                  # ヘルスチェック有効化
    healthy_threshold   = 2                     # 正常判定闾値（連続2回成功で正常）
    interval            = 30                    # チェック間隔（30秒）
    matcher             = "200"                 # 正常レスポンスコード
    path                = "/api/health"         # APIヘルスチェックエンドポイント
    port                = "traffic-port"        # トラフィックポートと同じポートでチェック
    protocol            = "HTTP"                # チェックプロトコル
    timeout             = 5                     # タイムアウト（5秒）
    unhealthy_threshold = 2                     # 異常判定闾値（連続2回失敗で異常）
  }

  tags = {
    Name = "${var.project_name}-backend-tg"
  }
}

# ==================================================
# ALBリスナー設定
# ==================================================
# クライアントからのリクエストを受け取り、適切なターゲットにルーティング

# HTTPリスナー（メインエントリポイント）
# デフォルトではフロントエンドにトラフィックを転送
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn  # アタッチするALBを指定
  port              = "80"            # HTTPポート（80）でリスン
  protocol          = "HTTP"          # HTTPプロトコル

  # デフォルトアクション（パスマッチしない場合）
  default_action {
    type             = "forward"                        # 転送アクション
    target_group_arn = aws_lb_target_group.frontend.arn # フロントエンドに転送
  }

  tags = {
    Name = "${var.project_name}-http-listener"
  }
}

# ==================================================
# ALBリスナールール設定
# ==================================================
# 特定のパスパターンに基づいてトラフィックを振り分け

# APIリクエスト用ルール
# "/api/*" パスのリクエストをバックエンドに転送
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn  # アタッチするリスナー
  priority     = 100                      # ルールの優先度（数値が小さいほど高優先）

  # アクション: バックエンドに転送
  action {
    type             = "forward"                       # 転送アクション
    target_group_arn = aws_lb_target_group.backend.arn # バックエンドに転送
  }

  # ルール条件: パスパターンマッチ
  condition {
    path_pattern {
      values = ["/api/*"]  # "/api/" で始まる全てのパスにマッチ
    }
  }

  tags = {
    Name = "${var.project_name}-api-rule"
  }
}