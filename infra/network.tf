# ==================================================
# ネットワーク設定 - Audio Slide App
# ==================================================
# 専用VPC、サブネット、セキュリティグループの設定
# セキュリティとネットワーク分離を強化するため専用VPCを使用
# - パブリックサブネット: ALB用（インターネット接続）
# - プライベートサブネット: ECSタスク用（NAT経由でインターネット接続）

# ==================================================
# 専用VPC作成
# ==================================================
# デフォルトVPCの代わりに、セキュリティを強化した専用VPCを作成

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr              # VPCのIPアドレス範囲
  enable_dns_hostnames = true                     # DNS ホスト名解決を有効化
  enable_dns_support   = true                     # DNS解決を有効化

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ==================================================
# インターネットゲートウェイ
# ==================================================
# VPCとインターネット間の通信を可能にするゲートウェイ

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ==================================================
# パブリックサブネット
# ==================================================
# ALB（Application Load Balancer）を配置するサブネット
# インターネットから直接アクセス可能

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true  # パブリックIP自動割り当て

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# ==================================================
# プライベートサブネット
# ==================================================
# ECSタスクを配置するサブネット
# インターネットアクセスはNATゲートウェイ経由

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "Private"
  }
}

# ==================================================
# Elastic IP（NATゲートウェイ用）
# ==================================================
# NATゲートウェイで使用する固定パブリックIPアドレス

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-eip-${count.index + 1}"
  }
}

# ==================================================
# NATゲートウェイ
# ==================================================
# プライベートサブネットからインターネットへの一方向通信を提供
# ECSタスクがECRやAWSサービスにアクセスするために必要

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-gw-${count.index + 1}"
  }
}

# ==================================================
# ルートテーブル（パブリック）
# ==================================================
# パブリックサブネット用のルーティング設定
# インターネットゲートウェイ経由で外部通信

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                    # 全ての宛先
    gateway_id = aws_internet_gateway.main.id   # インターネットゲートウェイ経由
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# パブリックサブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==================================================
# ルートテーブル（プライベート）
# ==================================================
# プライベートサブネット用のルーティング設定
# NATゲートウェイ経由で外部通信

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"                        # 全ての宛先
    nat_gateway_id = aws_nat_gateway.main[count.index].id # NATゲートウェイ経由
  }

  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

# プライベートサブネットとルートテーブルの関連付け
resource "aws_route_table_association" "private" {
  count = var.enable_nat_gateway ? length(aws_subnet.private) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ==================================================
# セキュリティグループ設定
# ==================================================

# ALB用セキュリティグループ
# インターネットからのHTTP/HTTPSアクセスを許可
resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.project_name}-alb-"  # ユニークな名前を自動生成
  description = "Security group for ${var.project_name} ALB - allows internet access"
  vpc_id      = aws_vpc.main.id

  # インバウンドルール: インターネットからのHTTPアクセスを許可
  ingress {
    description = "HTTP access on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 全てのIPアドレスからアクセス可能
  }

  # インバウンドルール: インターネットからのHTTPSアクセスを許可（将来のSSL対応用）
  ingress {
    description = "HTTPS access on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 全てのIPアドレスからアクセス可能
  }

  # アウトバウンドルール: 全ての外部アクセスを許可
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # 全プロトコル
    cidr_blocks = ["0.0.0.0/0"]   # 全ての宛先
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# ECSタスク用セキュリティグループ
# ALBからのトラフィックのみを許可し、セキュリティを強化
resource "aws_security_group" "ecs_sg" {
  name_prefix = "${var.project_name}-ecs-"  # ユニークな名前を自動生成
  description = "Security group for ${var.project_name} ECS tasks - allows access from ALB only"
  vpc_id      = aws_vpc.main.id

  # インバウンドルール: ALBからバックエンドポートへのアクセスを許可
  ingress {
    description     = "Backend access from ALB on port 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # ALBのセキュリティグループからのみ
  }

  # インバウンドルール: ALBからフロントエンドポートへのアクセスを許可
  ingress {
    description     = "Frontend access from ALB on port 80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # ALBのセキュリティグループからのみ
  }

  # アウトバウンドルール: 全ての外部アクセスを許可（API呼び出し、イメージダウンロード等用）
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # 全プロトコル
    cidr_blocks = ["0.0.0.0/0"]   # 全ての宛先
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}