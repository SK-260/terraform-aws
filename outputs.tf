output "ec2_public_ip" {
  value = aws_instance.web1.public_ip
}

output "db_instance_address" {
  value = aws_db_instance.project_db.address
}

output "lb_dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.project-alb.dncles_name
}