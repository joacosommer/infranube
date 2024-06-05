variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Infra en Nube - Martin Gulla - Joaquin Sommer"
  type        = string
  default     = "obligatorio-2"
}

variable "notification_email" {
  description = "The email address to receive notifications"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name to use for SSH access"
  type        = string
}
