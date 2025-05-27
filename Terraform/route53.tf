# Health check for primary (us-east-1) ALB
resource "aws_route53_health_check" "primary_alb" {
  fqdn              = aws_lb.multi-dr-alb-region1.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

# Health check for secondary (eu-west-1) ALB (optional but recommended)
resource "aws_route53_health_check" "secondary_alb" {
  fqdn              = aws_lb.multi-dr-alb-region2.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

# Route 53 PRIMARY record (us-east-1)
resource "aws_route53_record" "multi-dr-primary" {
  zone_id = var.route53_zone_id
  name    = "www.priyaraghunath.site"
  type    = "A"

  alias {
    name                   = aws_lb.multi-dr-alb-region1.dns_name
    zone_id                = aws_lb.multi-dr-alb-region1.zone_id
    evaluate_target_health = true
  }

  set_identifier = "primary-region"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary_alb.id
}

# Route 53 SECONDARY record (eu-west-1)
resource "aws_route53_record" "multi-dr-secondary" {
  zone_id = var.route53_zone_id
  name    = "www.priyaraghunath.site"
  type    = "A"

  alias {
    name                   = aws_lb.multi-dr-alb-region2.dns_name
    zone_id                = aws_lb.multi-dr-alb-region2.zone_id
    evaluate_target_health = true
  }

  set_identifier = "secondary-region"

  failover_routing_policy {
    type = "SECONDARY"
  }

  health_check_id = aws_route53_health_check.secondary_alb.id
}
