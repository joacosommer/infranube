variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "The name of the S3 bucket to trigger the Lambda function"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "function_filename" {
  description = "The filename of the Lambda function"
  type        = string
}

variable "environment" {
  description = "The environment variables to set for the Lambda function"
  type        = map
}
