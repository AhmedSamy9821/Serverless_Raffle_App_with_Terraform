#Out the role arn to use it on Lambda module to attach this role to the functions
output "lambda_role_arn" {
    value = aws_iam_role.lambda-role.arn
}