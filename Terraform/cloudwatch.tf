resource "aws_cloudwatch_metric_alarm" "rds_replication_alarm" {
  alarm_name          = "multi-dr-rds-replication-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  alarm_description   = "Triggers if RDS replica lag exceeds 60 seconds"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.multi-dr-rds-region2-replica.id
  }
  alarm_actions             = [aws_sns_topic.failover_alerts.arn]
  ok_actions                = [aws_sns_topic.failover_alerts.arn]
  treat_missing_data        = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "route53_healthcheck_alarm" {
  alarm_name          = "multi-dr-route53-healthcheck"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Triggers if Route 53 health check fails"
  dimensions = {
    HealthCheckId = aws_route53_health_check.primary_http_check.id
  }
  alarm_actions             = [aws_sns_topic.failover_alerts.arn]
  ok_actions                = [aws_sns_topic.failover_alerts.arn]
  treat_missing_data        = "breaching"
}

resource "aws_sns_topic" "failover_alerts" {
  name = "multi-dr-failover-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.failover_alerts.arn
  protocol  = "email"
  endpoint  = "priyaraghunath17@gmail.com"
}

resource "aws_route53_health_check" "primary_http_check" {
  fqdn              = "www.priyaraghunath.site"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}
