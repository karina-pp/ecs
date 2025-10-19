module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "ecs-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  name = "ecs-cluster-karina-training"

  configuration = {}


  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  tags = {
    Environment = "Development"
    Project     = "EcsEc2"
  }
}







# ECS Service Module
module "ecs_task_definition" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name           = "ecs-service-karina-training"
  cluster_arn    = module.ecs_cluster.arn
  create_service = true

  assign_public_ip = true

  # Task Definition
  volume = {}

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  container_definitions = {
    al2023 = {
      image = "kodekloud/ecommerce:apparels"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      mountPoints = [
        {

        }
      ]
    }
  }

  subnet_ids = module.vpc.public_subnets

  security_group_ingress_rules = {
    web = {
      from_port   = 8080
      to_port     = 8080
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "EcsKarinaTraining"
  }
}