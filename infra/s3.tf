# ==================================================
# S3設定 - Audio Slide App
# ==================================================
# 静的アセット（画像・音声ファイル）を保存するS3バケットを作成
# - 国旗、動物、単語の画像ファイル
# - 各カテゴリの音声ファイル（MP3）
# - パブリック読み取りアクセスを許可

# ==================================================
# メインS3バケット
# ==================================================
# アプリケーションで使用する全ての静的アセットを保存

resource "aws_s3_bucket" "assets" {
  bucket = var.s3_bucket_name  # 変数で定義されたバケット名

  tags = {
    Name = "${var.project_name}-assets"
  }
}

# ==================================================
# S3バケット設定
# ==================================================

# S3バケットのバージョニング設定
# ファイルの変更履歴を管理し、誤削除時の復元を可能にする
resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"  # バージョニングを有効化
  }
}

# S3バケットのサーバーサイド暗号化設定
# 保存されるデータのセキュリティを強化
resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    # デフォルトの暗号化設定
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # AWS管理のAES256暗号化を使用
    }
  }
}

# ==================================================
# S3パブリックアクセス設定
# ==================================================
# 静的アセットをWebアプリケーションから直接アクセスできるように設定

# S3バケットのパブリックアクセスブロック設定
# パブリック読み取りアクセスを許可するため、ブロックを無効化
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = false  # パブリックACLを許可
  block_public_policy     = false  # パブリックポリシーを許可
  ignore_public_acls      = false  # パブリックACLを無視しない
  restrict_public_buckets = false  # パブリックバケットを制限しない
}

# S3バケットポリシー（パブリック読み取りアクセス用）
# 全てのユーザーがオブジェクトを読み取り可能にする
resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id
  depends_on = [aws_s3_bucket_public_access_block.assets]  # パブリックアクセスブロック設定後に実行

  # パブリック読み取りアクセスを許可するポリシー
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"               # ステートメントID
        Effect    = "Allow"                           # アクセスを許可
        Principal = "*"                               # 全てのユーザー
        Action    = "s3:GetObject"                     # オブジェクトの読み取り権限
        Resource  = "${aws_s3_bucket.assets.arn}/*"   # バケット内の全オブジェクト
      }
    ]
  })
}

# ==================================================
# S3 CORS設定
# ==================================================
# Webアプリケーションからのクロスオリジンアクセスを許可
# ブラウザからのメディアファイルアクセスに必要

resource "aws_s3_bucket_cors_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  cors_rule {
    allowed_headers = ["*"]                    # 全てのリクエストヘッダーを許可
    allowed_methods = ["GET", "HEAD"]          # GETとHEADメソッドを許可（読み取り専用）
    allowed_origins = ["*"]                    # 全てのオリジンからのアクセスを許可
    expose_headers  = ["ETag"]                 # ETagヘッダーをクライアントに公開
    max_age_seconds = 3000                     # CORSプリフライトレスポンスのキャッシュ時間（秒）
  }
}