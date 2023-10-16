resource "aws_lb" "project-alb" {
  name = "ALB"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.alb-sg.id ]
  subnets = [ aws_subnet.publicsub-1.id, aws_subnet.publicsub-2.id]
}

resource "aws_lb_target_group" "project-tg" {
  name = "project-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.VPC.id

  depends_on = [ aws_vpc.VPC ]
}

resource "aws_lb_target_group_attachment" "tg-attach1" {
  target_group_arn = aws_lb_target_group.project-tg.arn
  target_id = aws_instance.web1.id
  port = 80

  depends_on = [ aws_instance.web1 ]
}

resource "aws_lb_target_group_attachment" "tg-attach2" {
  target_group_arn = aws_lb_target_group.project-tg.arn
  target_id = aws_instance.web2.id
  port = 80

  depends_on = [ aws_instance.web2 ]
}

resource "aws_lb_listener" "listener_lb" {
  load_balancer_arn = aws_lb_project-alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.project-tg.arn
  }
}

resource "aws_instance" "web1" {
  ami = "ami-0a5ac53f63249fba0"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  vpc_security_group_ids = [ aws_security_group.public-sg.id ]
  subnet_id = aws_subnet.publicsub-1.id
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "<html><body><h1>Hey there! Go refill your coffee. We have more to do!</h1></body></html>" > /var/www/html/index.html
    EOF
  tags = {
    name = "web1_instance"
  }
}

resource "aws_instance" "web2" {
  ami = "ami-0a5ac53f63249fba0"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1b"
  vpc_security_group_ids = [ aws_security_group.public-sg.id ]
  subnet_id = aws_subnet.publicsub-2.id
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "<html><body><h1>Hey fellow Terraform learners!</h1></body></html>" > /var/www/html/index.html
    EOF
  tags = {
    name = "web2_instance"
  }
}

resource "aws_db_subnet_group" "db-subnet" {
  name = "db-subnet"
  subnet_ids = [ aws_subnet.privatesub-1.id, aws_subnet.privatesub-2.id ]
}

resource "aws_db_instance" "project_db" {
  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.micro"
  identifier = "db-instance"
  db_name = "project_db"
  username = "admin"
  password = "Admin@123"
  db_subnet_group_name = aws_db_subnet_group.db-subnet.id
  vpc_security_group_ids = [ aws_security_group.private-sg.id ]
  publicly_accessible = false
  skip_final_snapshot = true
}