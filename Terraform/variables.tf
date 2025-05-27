// variables.tf

variable "region1" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "region2" {
  description = "Secondary AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_region1" {
  description = "VPC CIDR block for region 1"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_region2" {
  description = "VPC CIDR block for region 2"
  type        = string
  default     = "10.1.0.0/16"
}

variable "azs_region1" {
  description = "Availability Zones for region 1"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "azs_region2" {
  description = "Availability Zones for region 2"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnets_region1" {
  description = "Public subnets for region 1"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets_region2" {
  description = "Public subnets for region 2"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "ami_region1" {
  description = "AMI ID for region 1"
  type        = string
  default     = "ami-0e449927258d45bc4"
}

variable "ami_region2" {
  description = "AMI ID for region 2"
  type        = string
  default     = "ami-03d8b47244d950bbb"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = <<-EOT
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World! this is Priya's web page $(hostname -f)</h1>" > /var/www/html/index.html
  EOT
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage (in GB)"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  default     = "password1234"
  sensitive   = true
}

variable "route53_zone_id" {
  description = "The hosted zone ID for priyaraghunath.site"
  type        = string
}
