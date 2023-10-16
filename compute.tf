# Create the ALB
resource "aws_lb" "project-alb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.publicsub-1.id, aws_subnet.publicsub-2.id]
}

# Create the ALB target Group
resource "aws_lb_target_group" "project-tg" {
  name     = "project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id

  depends_on = [aws_vpc.VPC]
}

# Create the target attachments
resource "aws_lb_target_group_attachment" "tg-attach1" {
  target_group_arn = aws_lb_target_group.project-tg.arn
  target_id        = aws_instance.web1.id
  port             = 80

  depends_on = [aws_instance.web1]
}

resource "aws_lb_target_group_attachment" "tg-attach2" {
  target_group_arn = aws_lb_target_group.project-tg.arn
  target_id        = aws_instance.web2.id
  port             = 80

  depends_on = [aws_instance.web2]
}

#Create the listner
resource "aws_lb_listener" "listener_lb" {
  load_balancer_arn = aws_lb.project-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project-tg.arn
  }
}

# Create the EC2 instance
resource "aws_instance" "web1" {
  ami                         = var.AMIS
  instance_type               = var.web_instance_type
  availability_zone           = var.availability_zone[0]
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  subnet_id                   = aws_subnet.publicsub-1.id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata_web1.sh")

  tags = {
    name = "web1_instance"
  }
}

resource "aws_instance" "web2" {
  ami                         = var.AMIS
  instance_type               = var.web_instance_type
  availability_zone           = var.availability_zone[1]
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  subnet_id                   = aws_subnet.publicsub-2.id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata_web2.sh")
  tags = {
    name = "web2_instance"
  }
}

# Configure the database Private subnet group
resource "aws_db_subnet_group" "db-subnet" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.privatesub-1.id, aws_subnet.privatesub-2.id]
}

#Create the data base instance
resource "aws_db_instance" "project_db" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.db_instance_class
  identifier             = "db-instance"
  db_name                = "project_db"
  username               = var.db-username
  password               = var.db-password
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.id
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}