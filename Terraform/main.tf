// main.tf (final integrated version)

provider "aws" {
  alias  = "region1"
  region = var.region1
}

provider "aws" {
  alias  = "region2"
  region = var.region2
}

# ------------------------ SECURITY GROUPS ------------------------
resource "aws_security_group" "multi-dr-sg-region1" {
  provider    = aws.region1
  name        = "multi-dr-sg-region1"
  description = "Allow HTTP and MySQL"
  vpc_id      = aws_vpc.multi-dr-vpc-region1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "multi-dr-sg-region2" {
  provider    = aws.region2
  name        = "multi-dr-sg-region2"
  description = "Allow HTTP and MySQL"
  vpc_id      = aws_vpc.multi-dr-vpc-region2.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------ EC2 INSTANCES ------------------------
resource "aws_instance" "multi-dr-ec2-region1" {
  provider                = aws.region1
  ami                     = var.ami_region1
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.multi-dr-subnet-region1a.id
  vpc_security_group_ids  = [aws_security_group.multi-dr-sg-region1.id]
  user_data               = var.user_data

  tags = {
    Name = "multi-dr-ec2-region1"
  }
}

resource "aws_instance" "multi-dr-ec2-region2" {
  provider                = aws.region2
  ami                     = var.ami_region2
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.multi-dr-subnet-region2a.id
  vpc_security_group_ids  = [aws_security_group.multi-dr-sg-region2.id]
  user_data               = var.user_data

  tags = {
    Name = "multi-dr-ec2-region2"
  }
}

# ------------------------ S3 BUCKETS ------------------------
// S3 resources with correct provider usage, versioning fix, and replication dependency

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "multi-dr-s3-region1" {
  provider      = aws.region1
  bucket        = "multi-dr-s3-bucket-region1-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket" "multi-dr-s3-region2" {
  provider      = aws.region2
  bucket        = "multi-dr-s3-bucket-region2-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "multi-dr-versioning-region1" {
  provider = aws.region1
  bucket   = aws_s3_bucket.multi-dr-s3-region1.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "multi-dr-versioning-region2" {
  provider = aws.region2
  bucket   = aws_s3_bucket.multi-dr-s3-region2.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication_role" {
  provider = aws.region1
  name     = "multi-dr-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  provider = aws.region1
  name     = "multi-dr-s3-replication-policy"
  role     = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = ["${aws_s3_bucket.multi-dr-s3-region1.arn}/*"]
      },
      {
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = ["${aws_s3_bucket.multi-dr-s3-region2.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "multi-dr-replication" {
  provider   = aws.region1
  bucket     = aws_s3_bucket.multi-dr-s3-region1.id
  role       = aws_iam_role.replication_role.arn

  depends_on = [
    aws_s3_bucket_versioning.multi-dr-versioning-region1,
    aws_s3_bucket_versioning.multi-dr-versioning-region2
  ]

  rule {
    id     = "replication-rule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.multi-dr-s3-region2.arn
      storage_class = "STANDARD"
    }
  }
}

# ------------------------ RDS ------------------------
resource "aws_db_subnet_group" "multi-dr-db-subnet-group-region1" {
  provider   = aws.region1
  name       = "multi-dr-db-subnet-group-region1"
  subnet_ids = [
    aws_subnet.multi-dr-subnet-region1a.id,
    aws_subnet.multi-dr-subnet-region1b.id
  ]
}

resource "aws_db_subnet_group" "multi-dr-db-subnet-group-region2" {
  provider   = aws.region2
  name       = "multi-dr-db-subnet-group-region2"
  subnet_ids = [
    aws_subnet.multi-dr-subnet-region2a.id,
    aws_subnet.multi-dr-subnet-region2b.id
  ]
}

resource "aws_db_instance" "multi-dr-rds-region1" {
  provider                = aws.region1
  identifier              = "multi-dr-rds-primary"
  engine                  = "mysql"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.multi-dr-db-subnet-group-region1.name
  vpc_security_group_ids  = [aws_security_group.multi-dr-sg-region1.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
  backup_retention_period = 7

  tags = {
    Name = "multi-dr-rds-region1"
  }
}



resource "aws_db_instance" "multi-dr-rds-region2-replica" {
provider                = aws.region2
identifier              = "multi-dr-rds-replica"
replicate_source_db     = aws_db_instance.multi-dr-rds-region1.arn
instance_class          = var.db_instance_class
db_subnet_group_name    = aws_db_subnet_group.multi-dr-db-subnet-group-region2.name
vpc_security_group_ids  = [aws_security_group.multi-dr-sg-region2.id]
publicly_accessible     = true
skip_final_snapshot     = true
depends_on              = [aws_db_instance.multi-dr-rds-region1]
 backup_retention_period = 7
  
}



