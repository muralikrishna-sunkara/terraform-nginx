

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
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
    yum update -y
    
    # Install nginx
    amazon-linux-extras install nginx1 -y
    
    # Create custom HTML page
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Welcome to DevOps</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 20px;
            }
            .container {
                max-width: 1200px;
                margin: 0 auto;
                background: white;
                border-radius: 15px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                overflow: hidden;
            }
            .header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 40px;
                text-align: center;
            }
            .header h1 {
                font-size: 2.5em;
                margin-bottom: 10px;
            }
            .header p {
                font-size: 1.2em;
                opacity: 0.9;
            }
            .content {
                padding: 40px;
            }
            .workflow-section {
                margin-bottom: 40px;
            }
            .workflow-section h2 {
                color: #667eea;
                margin-bottom: 20px;
                font-size: 1.8em;
            }
            .workflow-images {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            .workflow-card {
                border: 2px solid #e0e0e0;
                border-radius: 10px;
                overflow: hidden;
                transition: transform 0.3s, box-shadow 0.3s;
            }
            .workflow-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }
            .workflow-card img {
                width: 100%;
                height: 200px;
                object-fit: cover;
            }
            .workflow-card .card-content {
                padding: 15px;
            }
            .workflow-card h3 {
                color: #333;
                margin-bottom: 8px;
            }
            .workflow-card p {
                color: #666;
                font-size: 0.9em;
            }
            .links-section {
                background: #f8f9fa;
                padding: 30px;
                border-radius: 10px;
            }
            .links-section h2 {
                color: #667eea;
                margin-bottom: 20px;
            }
            .links-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 15px;
            }
            .link-card {
                background: white;
                padding: 20px;
                border-radius: 8px;
                border-left: 4px solid #667eea;
                transition: all 0.3s;
            }
            .link-card:hover {
                transform: translateX(5px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }
            .link-card a {
                color: #667eea;
                text-decoration: none;
                font-weight: bold;
                font-size: 1.1em;
            }
            .link-card a:hover {
                color: #764ba2;
            }
            .link-card p {
                color: #666;
                font-size: 0.9em;
                margin-top: 8px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 Welcome to DevOps World..!</h1>
                <p>Automating, Integrating, and Delivering Excellence</p>
            </div>
            
            <div class="content">
                <div class="workflow-section">
                    <h2>DevOps CI/CD Pipeline Workflows</h2>
                    <div class="workflow-images">
                        <div class="workflow-card">
                            <img src="https://miro.medium.com/v2/resize:fit:1400/1*3qFdwzP6fu3xF2rmQ9VFJA.png" alt="CI/CD Pipeline">
                            <div class="card-content">
                                <h3>CI/CD Pipeline Flow</h3>
                                <p>Complete continuous integration and deployment workflow</p>
                            </div>
                        </div>
                        <div class="workflow-card">
                            <img src="https://www.jenkins.io/images/post-images/2023/09/kubernetes-cicd-with-jenkins/kubernetes-cicd-with-jenkins-pipeline.png" alt="Kubernetes CI/CD">
                            <div class="card-content">
                                <h3>Kubernetes Deployment</h3>
                                <p>Container orchestration and automated deployment</p>
                            </div>
                        </div>
                        <div class="workflow-card">
                            <img src="https://about.gitlab.com/images/devops-tools/gitlabcicd-overview.png" alt="GitLab CI/CD">
                            <div class="card-content">
                                <h3>GitOps Workflow</h3>
                                <p>Infrastructure as Code and version control integration</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="links-section">
                    <h2>🔗 Essential DevOps Resources</h2>
                    <div class="links-grid">
                        <div class="link-card">
                            <a href="https://www.jenkins.io/" target="_blank">Jenkins</a>
                            <p>Leading open-source automation server for CI/CD</p>
                        </div>
                        <div class="link-card">
                            <a href="https://kubernetes.io/" target="_blank">Kubernetes</a>
                            <p>Container orchestration platform</p>
                        </div>
                        <div class="link-card">
                            <a href="https://www.docker.com/" target="_blank">Docker</a>
                            <p>Containerization platform for applications</p>
                        </div>
                        <div class="link-card">
                            <a href="https://www.terraform.io/" target="_blank">Terraform</a>
                            <p>Infrastructure as Code tool by HashiCorp</p>
                        </div>
                        <div class="link-card">
                            <a href="https://prometheus.io/" target="_blank">Prometheus</a>
                            <p>Monitoring and alerting toolkit</p>
                        </div>
                        <div class="link-card">
                            <a href="https://grafana.com/" target="_blank">Grafana</a>
                            <p>Analytics and monitoring visualization</p>
                        </div>
                        <div class="link-card">
                            <a href="https://www.ansible.com/" target="_blank">Ansible</a>
                            <p>Automation and configuration management</p>
                        </div>
                        <div class="link-card">
                            <a href="https://about.gitlab.com/" target="_blank">GitLab</a>
                            <p>Complete DevOps platform with CI/CD</p>
                        </div>
                        <div class="link-card">
                            <a href="https://github.com/" target="_blank">GitHub Actions</a>
                            <p>CI/CD automation for GitHub repositories</p>
                        </div>
                        <div class="link-card">
                            <a href="https://aws.amazon.com/devops/" target="_blank">AWS DevOps</a>
                            <p>Cloud DevOps services and tools</p>
                        </div>
                        <div class="link-card">
                            <a href="https://helm.sh/" target="_blank">Helm</a>
                            <p>Package manager for Kubernetes</p>
                        </div>
                        <div class="link-card">
                            <a href="https://www.elastic.co/elk-stack" target="_blank">ELK Stack</a>
                            <p>Elasticsearch, Logstash, and Kibana for logging</p>
                        </div>
                    </div>
                </div>
            </div>
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