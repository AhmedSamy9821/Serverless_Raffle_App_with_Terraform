#Out the invoke arn for each function to be able to grantee the api permission to invoke it
output "functions_invoke_arn" {
    value = [ for function in aws_lambda_function.function_create : function.invoke_arn ]
}