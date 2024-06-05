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

module "product_images_bucket" {
  source       = "./modules/s3_bucket"
  bucket_name  = "${var.project_name}-product-images"
  project_name = var.project_name
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

module "ec2_site_bucket" {
  source       = "./modules/s3_bucket"
  bucket_name  = "${var.project_name}-ec2-site"
  project_name = var.project_name
}

# # need to set the policy for the bucket to allow the EC2 instance to access it and copy the index.html file
# resource "aws_s3_bucket_policy" "ec2_site_bucket_policy" {
#   bucket = module.ec2_site_bucket.bucket_id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "s3:GetObject",
#         Resource  = "${module.ec2_site_bucket.bucket_arn}/*",
#       },
#     ],
#   })
# }

resource "aws_s3_object" "index_html_ec2" {
  bucket = module.ec2_site_bucket.bucket_name
  key    = "index.html"
  source = "./index.html"
  content_type = "text/html"
}

module "web_server" {
  source         = "./modules/ec2"
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  instance_name  = "${var.project_name}-web-server"
  user_data      = file("./web_server.sh")
  bucket_name    = module.ec2_site_bucket.bucket_name
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

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/lambda/${var.project_name}-logs"
  retention_in_days = 14
}
