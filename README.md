terraform-nginx
Terraform code to deploy NGINX

Overview
This repository contains Terraform configurations that automate the deployment of an NGINX web server. All infrastructure code is written in HCL, making it easy to customize and deploy NGINX in various environments.

Features
Provision and configure NGINX automatically
Written entirely in HCL for modularity and reusability
Easily customizable for different cloud providers or environments
Prerequisites
Terraform installed
Access to your preferred cloud provider (e.g., AWS, Azure, GCP)
Proper credentials configured for Terraform
Getting Started
Clone the repository:

bash
git clone https://github.com/muralikrishna-sunkara/terraform-nginx.git
cd terraform-nginx
Initialize Terraform:

bash
terraform init
Review and customize variables (if needed):

Edit the variables.tf file to adjust resource parameters.
Plan the deployment:

bash
terraform plan
Apply the configuration:

bash
terraform apply
Confirm when prompted.
Access NGINX:

After deployment, note the output for the server’s public IP address and visit it in your browser.
Customization
Modify resource definitions in the main configuration files to suit your needs.
Add modules for additional infrastructure components.
Contributing
Contributions are welcome! Open an issue or submit a pull request.
