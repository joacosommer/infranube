output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_role_id" {
  description = "The ID of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_exec.id
}