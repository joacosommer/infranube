variable "name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic to allow sending messages to the SQS queue"
  type        = string
}
