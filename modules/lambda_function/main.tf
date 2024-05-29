resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "${var.function_filename}.lambda_handler"
  runtime       = "python3.8"

  # lambas are in the "lambdas/{function_name}/" directory
  source_code_hash = filebase64sha256("lambdas/${var.function_filename}/${var.function_filename}.zip")
  filename = "lambdas/${var.function_filename}/${var.function_filename}.zip"

  environment {
    variables = var.environment
  }

  tags = {
    Project = var.project_name
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy]
}

resource "aws_iam_role" "lambda_exec" {
  name = var.function_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
