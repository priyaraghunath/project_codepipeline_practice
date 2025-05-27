# elb.tf

# Region 1: us-east-1
resource "aws_lb" "multi-dr-alb-region1" {
  provider           = aws.region1
  name               = "multi-dr-alb-region1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.multi-dr-sg-region1.id]
  subnets            = [
    aws_subnet.multi-dr-subnet-region1a.id,
    aws_subnet.multi-dr-subnet-region1b.id
  ]

  tags = {
    Name = "multi-dr-alb-region1"
  }
}

resource "aws_lb_target_group" "multi-dr-tg-region1" {
  provider = aws.region1
  name     = "multi-dr-tg-region1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.multi-dr-vpc-region1.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "multi-dr-tg-region1"
  }
}

resource "aws_lb_listener" "multi-dr-listener-region1" {
  provider          = aws.region1
  load_balancer_arn = aws_lb.multi-dr-alb-region1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.multi-dr-tg-region1.arn
  }
}

resource "aws_lb_target_group_attachment" "multi-dr-ec2-attach-region1" {
  provider         = aws.region1
  target_group_arn = aws_lb_target_group.multi-dr-tg-region1.arn
  target_id        = aws_instance.multi-dr-ec2-region1.id
  port             = 80
}

# Region 2: eu-west-1
resource "aws_lb" "multi-dr-alb-region2" {
  provider           = aws.region2
  name               = "multi-dr-alb-region2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.multi-dr-sg-region2.id]
  subnets            = [
    aws_subnet.multi-dr-subnet-region2a.id,
    aws_subnet.multi-dr-subnet-region2b.id
  ]

  tags = {
    Name = "multi-dr-alb-region2"
  }
}

resource "aws_lb_target_group" "multi-dr-tg-region2" {
  provider = aws.region2
  name     = "multi-dr-tg-region2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.multi-dr-vpc-region2.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "multi-dr-tg-region2"
  }
}

resource "aws_lb_listener" "multi-dr-listener-region2" {
  provider          = aws.region2
  load_balancer_arn = aws_lb.multi-dr-alb-region2.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.multi-dr-tg-region2.arn
  }
}

resource "aws_lb_target_group_attachment" "multi-dr-ec2-attach-region2" {
  provider         = aws.region2
  target_group_arn = aws_lb_target_group.multi-dr-tg-region2.arn
  target_id        = aws_instance.multi-dr-ec2-region2.id
  port             = 80
}
