variable "ami_id" {
  description = "The AMI ID to use for the instance"
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

variable "instance_name" {
  description = "The name to tag the instance with"
  type        = string
}

variable "user_data" {
  description = "The user data to provide at instance launch"
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
