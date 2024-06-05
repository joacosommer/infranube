output "static_site_bucket_name" {
  value = module.static_site_bucket.bucket_name
}

output "orders_bucket_name" {
  value = module.orders_bucket.bucket_name
}

output "product_images_bucket_name" {
  value = module.product_images_bucket.bucket_name
}

output "order_processing_lambda_name" {
  value = module.order_processing_lambda.lambda_function_name
}

output "static_website_url" {
  description = "URL del sitio estatico"
  value = aws_s3_bucket_website_configuration.website_configuration.website_endpoint 
}

output "ec2_dinamic_website_url" {
  description = "URL del sitio dinamico"
  value = module.web_server.public_dns
}