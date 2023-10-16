variable "aws_region" {
  description = "AWS region to deploy the infrastructure"
  default     = "ap-south-1"
}

variable "vpc-cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public-subnet" {
  description = "CIDR Block for public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private-subnet" {
  description = "CIDR Block for private subnet"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "web_instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "RDS instance class for the database"
  default     = "db.t3.micro"
}

variable "db-username" {
  description = "Username for the RDS instance"
  default     = "admin"
}

variable "db-password" {
  description = "Password for the RDS instance"
  sensitive   = true
}

variable "availability_zone" {
  description = "Varlous availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "AMIS" {
  description = "Ami for the EC2 instance"
  default     = "ami-0a5ac53f63249fba0"
}