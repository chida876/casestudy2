# Define AWS provider

provider "aws" {
  region = "your-region"
}

# Create ALBs for blue and green environments

resource "aws_lb" "blue" {
  name               = "blue-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-12345678", "subnet-87654321"]
  security_groups    = ["sg-abcdef12"]
}

resource "aws_lb" "green" {
  name               = "green-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-12345678", "subnet-87654321"]
  security_groups    = ["sg-abcdef12"]
}

# Create Route 53 DNS records

resource "aws_route53_record" "blue_alias" {
  zone_id = "your-zone-id"
  name    = "blue.example.com"
  type    = "A"
  alias {
    name                   = aws_lb.blue.dns_name
    zone_id                = aws_lb.blue.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "green_alias" {
  zone_id = "your-zone-id"
  name    = "green.example.com"
  type    = "A"
  alias {
    name                   = aws_lb.green.dns_name
    zone_id                = aws_lb.green.zone_id
    evaluate_target_health = true
  }
}

# Define Auto Scaling Groups for blue and green environments

resource "aws_autoscaling_group" "blue" {
  name             = "blue-asg"
  min_size         = 1
  max_size         = 3
  desired_capacity = 2
  launch_template {
    id = "blue-launch-template-id"
  }
  vpc_zone_identifier = ["subnet-12345678", "subnet-87654321"]
}

resource "aws_autoscaling_group" "green" {
  name             = "green-asg"
  min_size         = 1
  max_size         = 3
  desired_capacity = 2
  launch_template {
    id = "green-launch-template-id"
  }
  vpc_zone_identifier = ["subnet-12345678", "subnet-87654321"]
}

# Configure SSL certificate for ALB listeners

resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = {
    Name = "example-com-cert"
  }
}

resource "aws_lb_listener" "blue_https" {
  load_balancer_arn = aws_lb.blue.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.ssl_cert.arn
}

resource "aws_lb_listener" "green_https" {
  load_balancer_arn = aws_lb.green.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.ssl_cert.arn
}

# Define Route 53 DNS records pointing to ALB endpoints

resource "aws_route53_record" "blue_dns" {
  zone_id = "your-zone-id"
  name    = "blue.example.com"
  type    = "A"
  alias {
    name                   = aws_lb.blue.dns_name
    zone_id                = aws_lb.blue.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "green_dns" {
  zone_id = "your-zone-id"
  name    = "green.example.com"
  type    = "A"
  alias {
    name                   = aws_lb.green.dns_name
    zone_id                = aws_lb.green.zone_id
    evaluate_target_health = true
  }
}
