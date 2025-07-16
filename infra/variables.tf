# ==================================================
# Terraform変数定義 - Audio Slide App
# ==================================================
# このファイルはインフラ全体で使用される変数を定義します
# terraform.tfvarsファイルでデフォルト値を上書き可能です

# ==================================================
# プロジェクト基本設定
# ==================================================

variable "project_name" {
  description = "プロジェクト名（リソース名のプレフィックスとして使用）"
  type        = string
  default     = "audio-slide-app"
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 50
    error_message = "プロジェクト名は1文字以上50文字以下で入力してください。"
  }
}

variable "environment" {
  description = "環境名（prod, dev, staging等）"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["prod", "dev", "staging"], var.environment)
    error_message = "環境名はprod, dev, stagingのいずれかで入力してください。"
  }
}

variable "aws_region" {
  description = "AWSリージョン（リソースを作成する地域）"
  type        = string
  default     = "ap-northeast-1"  # 東京リージョン
}

# ==================================================
# ネットワーク関連設定
# ==================================================

variable "vpc_cidr" {
  description = "専用VPCのCIDRブロック（プライベートIPアドレス範囲）"
  type        = string
  default     = "10.0.0.0/16"  # 65,536個のIPアドレスを提供
}

variable "availability_zones" {
  description = "使用するアベイラビリティゾーンのリスト（高可用性用）"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]  # 東京リージョンの2つのAZ
}

variable "public_subnet_cidrs" {
  description = "パブリックサブネットのCIDRブロックリスト（ALB用）"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]  # 各AZに256個のIPアドレス
}

variable "private_subnet_cidrs" {
  description = "プライベートサブネットのCIDRブロックリスト（ECSタスク用）"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]  # 各AZに256個のIPアドレス
}

variable "enable_nat_gateway" {
  description = "NATゲートウェイを有効化するか（プライベートサブネットのインターネットアクセス用）"
  type        = bool
  default     = true  # ECSタスクがECRや他AWSサービスにアクセスするため必要
}

# ==================================================
# ECS関連設定
# ==================================================

variable "cluster_name" {
  description = "ECSクラスター名（アプリケーションを実行するコンテナ群）"
  type        = string
  default     = "audio-slide-cluster"
}

# ==================================================
# ECR関連設定（Dockerイメージリポジトリ）
# ==================================================

variable "ecr_backend_repo" {
  description = "バックエンド用ECRリポジトリ名（Go/Gin APIサーバー）"
  type        = string
  default     = "audio-slide-backend"
}

variable "ecr_frontend_repo" {
  description = "フロントエンド用ECRリポジトリ名（Reactアプリケーション）"
  type        = string
  default     = "audio-slide-frontend"
}

# ==================================================
# ストレージ関連設定
# ==================================================

variable "s3_bucket_name" {
  description = "S3バケット名（画像・音声ファイル等の静的アセット用）"
  type        = string
  default     = "audio-slide-app-assets"
}

variable "dynamodb_table_name" {
  description = "DynamoDBテーブル名（クイズデータ等のアプリケーションデータ用）"
  type        = string
  default     = "Quiz"
}

# ==================================================
# アプリケーション設定
# ==================================================

variable "app_version" {
  description = "アプリケーションのバージョンタグ（Dockerイメージのタグとして使用）"
  type        = string
  default     = "0.5"
}

# ==================================================
# ECSタスクリソース設定
# ==================================================
# FargateタスクのCPUとメモリ設定
# CPU: 256(0.25vCPU), 512(0.5vCPU), 1024(1vCPU)等
# メモリ: CPUに対応した範囲で設定可能

variable "backend_cpu" {
  description = "バックエンドタスクのCPUユニット（256 = 0.25vCPU）"
  type        = number
  default     = 256
  
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.backend_cpu)
    error_message = "CPUは256, 512, 1024, 2048, 4096のいずれかで指定してください。"
  }
}

variable "backend_memory" {
  description = "バックエンドタスクのメモリ（MB）"
  type        = number
  default     = 512
  
  validation {
    condition     = var.backend_memory >= 512 && var.backend_memory <= 30720
    error_message = "メモリは512MB以上30720MB以下で指定してください。"
  }
}

variable "frontend_cpu" {
  description = "フロントエンドタスクのCPUユニット（256 = 0.25vCPU）"
  type        = number
  default     = 256
  
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.frontend_cpu)
    error_message = "CPUは256, 512, 1024, 2048, 4096のいずれかで指定してください。"
  }
}

variable "frontend_memory" {
  description = "フロントエンドタスクのメモリ（MB）"
  type        = number
  default     = 512
  
  validation {
    condition     = var.frontend_memory >= 512 && var.frontend_memory <= 30720
    error_message = "メモリは512MB以上30720MB以下で指定してください。"
  }
}

# ==================================================
# ECSサービススケーリング設定
# ==================================================
# 各サービスで実行するタスク数を指定

variable "backend_desired_count" {
  description = "バックエンドサービスの希望タスク数（スケーリング用）"
  type        = number
  default     = 1
  
  validation {
    condition     = var.backend_desired_count >= 1 && var.backend_desired_count <= 10
    error_message = "タスク数は1以上10以下で指定してください。"
  }
}

variable "frontend_desired_count" {
  description = "フロントエンドサービスの希望タスク数（スケーリング用）"
  type        = number
  default     = 1
  
  validation {
    condition     = var.frontend_desired_count >= 1 && var.frontend_desired_count <= 10
    error_message = "タスク数は1以上10以下で指定してください。"
  }
}