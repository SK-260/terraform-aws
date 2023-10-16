# AWS Two Tier Architecture with Terraform

This repository contains Terraform configuration files to set up a two-tier architecture on AWS, including a VPC, database, and compute resources. The infrastructure consists of public-facing web servers and a MySQL database in separate subnets for better security and isolation.

**Architecture Overview**<br>
- VPC with public and private subnets
- Application Load Balancer (ALB) for web 
- MySQL RDS instance for database 
- Security groups to control traffic between the tiers