module "vpc" {
  source = "./modules/vpc"

  vpc_name           = "devops-production-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-central-1a", "eu-central-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true  # Set to true to use only one NAT Gateway (cost savings)

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Project     = "devops-project"
  }
}