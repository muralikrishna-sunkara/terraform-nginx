

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "nginx-web-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-web-sg"
  }
}

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-ssm-role"
  }
}

# Attach SSM policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# User data script to install nginx
locals {
  user_data = <<-EOF
    #!/bin/bash
    # Update system
    dnf update -y
    
    # Install nginx
    dnf install -y nginx
    
    # Create custom HTML page
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Welcome to DevOps</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            }
            .container {
                text-align: center;
                color: white;
                padding: 40px;
                border-radius: 10px;
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
            }
            h1 {
                font-size: 3em;
                margin: 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Welcome to DevOps world..!</h1>
        </div>
    </body>
    </html>
    HTML
    
    # Start and enable nginx
    systemctl start nginx
    systemctl enable nginx
  EOF
}

# EC2 Instance
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  subnet_id = module.vpc.public_subnet_ids[0]
  user_data = local.user_data

  # Ensure public IP is assigned
  associate_public_ip_address = true

  tags = {
    Name = "nginx-devops-server"
  }
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.nginx_server.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.nginx_server.public_ip
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_instance.nginx_server.public_ip}"
}