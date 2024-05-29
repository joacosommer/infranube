resource "aws_sns_topic" "this" {
  name = var.name
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

output "arn" {
  value = aws_sns_topic.this.arn
}
