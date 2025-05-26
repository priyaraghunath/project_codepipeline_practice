// variables.tf

variable "region1" {
  default = "us-east-1"
}

variable "region2" {
  default = "eu-west-1"
}

variable "vpc_cidr_region1" {
  default = "10.0.0.0/16"
}

variable "vpc_cidr_region2" {
  default = "10.1.0.0/16"
}

variable "azs_region1" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "azs_region2" {
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnets_region1" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets_region2" {
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}



variable "ami_region1" {
  default = "ami-0e449927258d45bc4"
}

variable "ami_region2" {
  default = "ami-03d8b47244d950bbb"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "user_data" {
  default = <<-EOT
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World! this is Priya's web page $(hostname -f)</h1>" > /var/www/html/index.html
  EOT
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  default = 20
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "password1234"
}
