# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights" // コンテナインサイトを有効化
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    // デフォルトのキャパシティプロバイダー戦略を設定
    // デフォルトでは1つのFARGATEプロバイダーを使用
    // この設定により、FARGATEプロバイダーがデフォルトで使用されるようになる
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# ECS Task Definition for Backend
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  # ランタイムプラットフォーム設定
  runtime_platform {
    operating_system_family = "LINUX"  # Linux OSを使用
    cpu_architecture        = "ARM64"  # ARM64アーキテクチャ（Graviton2コスト最適化）
  }

  container_definitions = jsonencode([
    {
      name  = "${var.project_name}-backend"
      image = "${aws_ecr_repository.backend.repository_url}:${var.app_version}"
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "PORT"
          value = "8080"
        },
        {
          name  = "S3_BUCKET_NAME"
          value = var.s3_bucket_name
        },
        {
          name  = "S3_REGION"
          value = var.aws_region
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      essential = true
    }
  ])

  tags = {
    Name = "${var.project_name}-backend-task"
  }
}

# ECS Task Definition for Frontend
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # ランタイムプラットフォーム設定
  runtime_platform {
    operating_system_family = "LINUX"  # Linux OSを使用
    cpu_architecture        = "ARM64"  # ARM64アーキテクチャ（Graviton2コスト最適化）
  }

  container_definitions = jsonencode([
    {
      name  = "${var.project_name}-frontend"
      image = "${aws_ecr_repository.frontend.repository_url}:${var.app_version}"
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      essential = true
    }
  ])

  tags = {
    Name = "${var.project_name}-frontend-task"
  }
}

# ECS Service for Backend
resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private[*].id    # プライベートサブネットに配置
    assign_public_ip = false                       # プライベートサブネットのためパブリックIP不要
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${var.project_name}-backend"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${var.project_name}-backend-service"
  }
}

# ECS Service for Frontend
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private[*].id    # プライベートサブネットに配置
    assign_public_ip = false                       # プライベートサブネットのためパブリックIP不要
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "${var.project_name}-frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${var.project_name}-frontend-service"
  }
}