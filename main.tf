module "static_site_bucket" {
  source       = "./modules/s3_bucket"
  bucket_name  = "${var.project_name}-static-site"
  project_name = var.project_name
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = module.static_site_bucket.bucket_id

  block_public_policy     = false
  restrict_public_buckets = false 
  block_public_acls       = false 
  ignore_public_acls      = false 
}

resource "aws_s3_bucket_policy" "hosting_policy" {
  bucket = module.static_site_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${module.static_site_bucket.bucket_name}/*",
      },
    ],
  })
}

resource "aws_s3_object" "index_html" {
  bucket = module.static_site_bucket.bucket_id
  key    = "index.html"
  source = "./index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = module.static_site_bucket.bucket_id

  index_document {
    suffix = "index.html"
  }
}

module "orders_bucket" {
  source       = "./modules/s3_bucket"
  bucket_name  = "${var.project_name}-orders"
  project_name = var.project_name
}

module "sns" {
  source             = "./modules/sns"
  name               = "${var.project_name}-order-notifications"
  notification_email = var.notification_email
}

module "sqs" {
  source        = "./modules/sqs"
  name          = "${var.project_name}-order-queue"
  sns_topic_arn = module.sns.arn
}

module "order_processing_lambda" {
  source            = "./modules/lambda_function"
  function_name     = "${var.project_name}-order-processing"
  s3_bucket         = module.orders_bucket.bucket_name
  project_name      = var.project_name
  function_filename = "order_processing_lambda"
  environment = {
    S3_BUCKET     = module.orders_bucket.bucket_name
    SNS_TOPIC_ARN = module.sns.arn
  }
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_policy"
  role = module.order_processing_lambda.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ],
        Effect = "Allow",
        Resource = [
          "${module.orders_bucket.bucket_arn}/*",
        ],
      },
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = module.sns.arn
      }
    ],
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.orders_bucket.bucket_name

  lambda_function {
    lambda_function_arn = module.order_processing_lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.order_processing_lambda.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.orders_bucket.bucket_arn
}

# resource "aws_lambda_event_source_mapping" "order_queue_event" {
#   event_source_arn = module.sqs.arn
#   function_name    = module.order_processing_lambda.lambda_function_arn
#   batch_size       = 10
#   enabled          = true
# }

# resource "aws_cloudfront_distribution" "cdn" {
#   origin {
#     domain_name = "${module.static_site_bucket.bucket_name}.s3.amazonaws.com"
#     origin_id   = "S3-${module.static_site_bucket.bucket_name}"

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
#     }
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "CloudFront distribution for static site"
#   default_root_object = "index.html"

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3-${module.static_site_bucket.bucket_name}"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   tags = {
#     Environment = "production"
#   }
# }

# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   comment = "Origin access identity for static site bucket"
# }

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/lambda/${var.project_name}-logs"
  retention_in_days = 14
}

# resource "aws_cloudtrail" "main" {
#   name                          = "${var.project_name}-cloudtrail"
#   s3_bucket_name                = module.orders_bucket.bucket_name
#   include_global_service_events = true
#   is_multi_region_trail         = true
#   enable_log_file_validation    = true
#   cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.application_logs.arn
#   cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
# }

# resource "aws_iam_role" "cloudtrail_role" {
#   name = "${var.project_name}-cloudtrail-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudtrail.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "cloudtrail_policy" {
#   role       = aws_iam_role.cloudtrail_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCloudTrailLoggingPolicy"
# }

