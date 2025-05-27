To design and implement a multi-region disaster recovery solution using AWS services, where infrastructure is deployed in two AWS regions. The solution will replicate data across regions, ensure high availability, and implement a failover mechanism for disaster recovery. The project involves using Terraform to provision infrastructure, and CI/CD pipelines to ensure both regions remain synchronized for disaster recovery and failover.


![image](https://github.com/user-attachments/assets/0c77c513-143f-44d8-9001-839070933843)



**Architecture Overview:** This AWS architecture demonstrates a highly available web application distributed across two regions (Region 01 and Region 02) with redundant EC2 instances deployed in the Web and App tiers. Elastic Load Balancers (ELB) are placed at both regional entry points to distribute incoming traffic evenly and maintain service continuity during failures. Amazon RDS is used in both regions for the Data Tier, ensuring high availability and durability of data through replication. The setup leverages Amazon Route 53 for global DNS routing and Amazon S3 for static content storage, enhancing performance and global reach via caching. Infrastructure is provisioned using Terraform and automated via Jenkins, enabling continuous integration and deployment, while the multi-region, multi-tier design ensures fault tolerance, scalability, and minimal downtime.

**•	Regions Used: us-east-1 (Primary), eu-west-1 (Secondary)
•	Services:**
o	Amazon VPC (Networking)
o	Amazon EC2 (Web Servers)
o	Amazon S3 with Cross-Region Replication
o	Amazon RDS with Read Replica
o	AWS ALB (Load Balancers in each region)
o	Route 53 with Failover Routing
o	CloudWatch Alarms and Route 53 Health Checks
o	SNS Notifications for failover and replication alerts



![image](https://github.com/user-attachments/assets/68e02453-2046-40be-bb78-8e05a9b1e9dd)



**Configure Terraform Backend (backend.tf):**
To centrally and securely store your Terraform state file in S3 and use DynamoDB for state locking (to prevent simultaneous changes and state corruption), follow these steps and commands:
create an S3 bucket and enable versioning using the AWS CLI:
* aws s3api create-bucket --bucket bucket-terraform-Logstore --region us-east-1

* aws s3api put-bucket-versioning --bucket bucket-terraform-Logstore --versioning-configuration Status=Enabled
   
Create a DynamoDB table with a primary key named LockID:
* aws dynamodb create-table --table-name Terraform-Logstor --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region us-east-1

Configure terraform backend:
terraform {
  backend "s3" {
    bucket         = " bucket-terraform-Logstore"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = " Terraform-Logstor"
  }
}






