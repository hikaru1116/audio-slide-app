# ==================================================
# ECR設定 - Audio Slide App
# ==================================================
# Dockerイメージを保存するECRリポジトリを作成
# バックエンド（Go/Gin）とフロントエンド（React）用を別々に作成

# ==================================================
# バックエンド用ECRリポジトリ
# ==================================================
# Go/Ginで構築されたAPIサーバーのDockerイメージを保存

resource "aws_ecr_repository" "backend" {
  name                 = var.ecr_backend_repo  # 変数で定義されたリポジトリ名
  image_tag_mutability = "MUTABLE"            # イメージタグの上書きを許可（開発時の利便性を重視）

  # イメージの脆弱性スキャン設定
  image_scanning_configuration {
    scan_on_push = true  # イメージプッシュ時に自動で脆弱性スキャンを実行
  }

  tags = {
    Name = "${var.project_name}-backend-ecr"
  }
}

# ==================================================
# フロントエンド用ECRリポジトリ
# ==================================================
# Reactで構築されたWebアプリケーションのDockerイメージを保存

resource "aws_ecr_repository" "frontend" {
  name                 = var.ecr_frontend_repo  # 変数で定義されたリポジトリ名
  image_tag_mutability = "MUTABLE"             # イメージタグの上書きを許可（開発時の利便性を重視）

  # イメージの脆弱性スキャン設定
  image_scanning_configuration {
    scan_on_push = true  # イメージプッシュ時に自動で脆弱性スキャンを実行
  }

  tags = {
    Name = "${var.project_name}-frontend-ecr"
  }
}

# ==================================================
# ECRライフサイクルポリシー
# ==================================================
# 古いDockerイメージを自動削除してストレージコストを節約
# 最新の10個のイメージのみを保持し、古いモノは自動削除

# バックエンド用ライフサイクルポリシー
resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name

  # ライフサイクルルールをJSONで定義
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1                          # ルールの優先度（数値が小さいほど高優先）
        description  = "最新の10個のイメージを保持、それ以外を削除"
        selection = {
          tagStatus     = "tagged"                # タグ付きイメージを対象
          tagPrefixList = ["v"]                   # "v"で始まるタグ（v1.0, v2.0等）を対象
          countType     = "imageCountMoreThan"    # 数量ベースの管理
          countNumber   = 10                      # 10個を超えた場合に削除
        }
        action = {
          type = "expire"  # 期限切れアクション（削除）
        }
      }
    ]
  })
}

# フロントエンド用ライフサイクルポリシー
resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name

  # ライフサイクルルールをJSONで定義
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1                          # ルールの優先度（数値が小さいほど高優先）
        description  = "最新の10個のイメージを保持、それ以外を削除"
        selection = {
          tagStatus     = "tagged"                # タグ付きイメージを対象
          tagPrefixList = ["v"]                   # "v"で始まるタグ（v1.0, v2.0等）を対象
          countType     = "imageCountMoreThan"    # 数量ベースの管理
          countNumber   = 10                      # 10個を超えた場合に削除
        }
        action = {
          type = "expire"  # 期限切れアクション（削除）
        }
      }
    ]
  })
}