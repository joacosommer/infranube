output "static_site_bucket_name" {
  value = module.static_site_bucket.bucket_name
}

output "orders_bucket_name" {
  value = module.orders_bucket.bucket_name
}

output "order_processing_lambda_name" {
  value = module.order_processing_lambda.lambda_function_name
}
