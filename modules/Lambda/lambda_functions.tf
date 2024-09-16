##########
#This module is for creating lambda functions
##########

#This logic is to decide if we work with dev directory or prod directory according to the environment
locals {
  code_directory = {
    "dev"  = var.functions_dev_directory
    "prod" = var.functions_prod_directory 
  }
}


#converts js file to zip file to be able to identifyable for lambda function
data "archive_file" "function_zip" {
  type        = "zip"
  source_file = "${lookup(local.code_directory , "${terraform.workspace}" , "../${terraform.workspace}") }/${var.function_name[count.index]}/index.mjs"
  output_path = "../${terraform.workspace}_code_zip/${var.function_name[count.index]}.zip"
  count = length(var.function_name) 
}


#create function
resource "aws_lambda_function" "function_create" {
  
  filename      = "../${terraform.workspace}_code_zip/${var.function_name[count.index]}.zip"
  function_name = "${terraform.workspace}_${var.function_name[count.index]}_function"
  role          = var.lambda_role_arn
 
  handler       = "index.handler"
  source_code_hash = data.archive_file.function_zip[count.index].output_base64sha256

  runtime = "nodejs20.x"

   depends_on = [
    data.archive_file.function_zip
  ]

  count = length(var.function_name) 
  tags = {
    Environment = "${terraform.workspace}"
  }

}