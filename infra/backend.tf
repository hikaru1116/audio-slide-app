# ==================================================
# Terraform設定 - Audio Slide App インフラストラクチャ
# ==================================================
# このファイルはTerraformの基本設定を定義します
# - プロバイダーバージョン管理
# - S3リモートバックエンド設定
# - AWSプロバイダー設定

terraform {
  # Terraformのバージョン要件
  required_version = ">= 1.0"

  # 使用するプロバイダーとバージョンを定義
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # AWS Provider v5.x系を使用
    }
  }

  # Terraformの状態ファイルをS3に保存（リモートバックエンド）
  # 注意: 事前にS3バケットとDynamoDBテーブルの手動作成が必要
  backend "s3" {
    bucket = "audio-slide-app-terraform-state"  # 状態ファイル保存用S3バケット
    key    = "terraform.tfstate"               # 状態ファイル名
    region = "ap-northeast-1"                  # S3バケットのリージョン
    
    encrypt        = true                      # 状態ファイルを暗号化
    # dynamodb_table = "audio-slide-app-terraform-locks"  # ロック用DynamoDBテーブル（オプション）
  }
}

# ==================================================
# AWSプロバイダー設定
# ==================================================
# AWSリソースを管理するためのプロバイダー設定

provider "aws" {
  region = var.aws_region  # 変数で定義されたリージョンを使用

  # 全てのリソースに自動的に適用されるデフォルトタグ
  # リソース管理とコスト追跡に使用
  default_tags {
    tags = {
      Project     = var.project_name  # プロジェクト名
      Environment = var.environment   # 環境名（prod, dev等）
      ManagedBy   = "terraform"       # Terraformで管理されていることを示す
    }
  }
}