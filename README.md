# interncareer_task2
Implement infrastructure as code (IaC) Terraform to provision and manage cloud resources for a scalable web application
deployment.

# 1.launch ec2 instance
Login to AWS Console 
Navigate to EC2.
Click "Launch Instance." 
Choose the "t2.micro" instance type. 
Configure other settings (VPC, security groups, key pair, etc.).

# 2.installation of terraform

sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

Verify  :  terraform version

# aclaccess.json
In this json file the permission are provide which are required for the s3 bucket