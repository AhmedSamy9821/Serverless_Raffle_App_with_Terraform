#######################
#This is the root module of aws serverless app with any number of function you want
#######################


###################
#Dynamo_table module
#This module is for creating dynamoDB table to register the users 
###################
module "DynamoDB" {
  source = "../modules/Dynamo_table"
}


#################
#IAM module
#The purpose of this module is to create and attach IAM role to lambda to get full access to DynamoDB
# to be able to register the users on DynamoDB table
##################
module "IAM" {
  source = "../modules/IAM"
}


#################
#Lambda module
#This module is for creating lambda functions
#################
module "Lambda" {
  source = "../modules/Lambda"
  function_name = var.function_name
  functions_dev_directory = var.functions_dev_directory
  functions_prod_directory = var.functions_prod_directory
  lambda_role_arn = module.IAM.lambda_role_arn

  depends_on = [module.IAM]
}


###################
#API cert module
#This module is to create certificate for the api url 
###################
module "api_cert" {
  source = "../modules/API_cert"
  domain = var.domain
}


##################
#api gateway module
#This module for creating HTTP API gateway and integrate it with lambda functions
##################
module "api_gateway" {
  source = "../modules/API_gateway"
  domain = var.domain
  api_url = module.api_cert.api_url
  api_cert_arn = module.api_cert.api_cert_arn
  domain_zone_id = module.api_cert.zone_id
  invoke_arns = module.Lambda.functions_invoke_arn
  function_name = var.function_name
  route_key = var.route_key
  s3_url = module.S3_web_hosting.s3_url
  Cloud_Front_url = length( module.Cloud_Front) == 0 ? "there is no cloud distribution" : module.Cloud_Front[0].Cloud_Front_url

  depends_on = [ module.api_cert , module.Lambda ]
}


################
#S3 web hosting module
#This module is for creating s3 bucket bucket with name of your domain
#and enable s3 web hosting and upload the html pages for your app
################
module "S3_web_hosting" {
  source = "../modules/S3_web_hosting"
  domain = var.domain
  html_pages = var.html_pages
  html_dev_directory = var.html_dev_directory
  html_prod_directory = var.html_prod_directory
}

#####################
# in dev environment we will only make a record on route53 that redirect "dev.domain" to "S3 website_domain"
# but in production environment we will deploy Cloud fornt distribution
#####################

#create record for dev environment
resource "aws_route53_record" "dev_s3_record" {
  count = "${terraform.workspace}" == "dev" ? 1 : 0 #if the environment is not "dev" don't create the resource

  zone_id = module.api_cert.zone_id
  name    = "dev.${var.domain}"
  type    = "A"

  alias {
    name                   = module.S3_web_hosting.s3_website_domain
    zone_id                = module.S3_web_hosting.s3_zone_id
    evaluate_target_health = false
  }
}


######################
#Cloud front distribution module for production environment
#This module is for creating certification and cloud distribution of your domain
#and serve the content from s3 origin 
module "Cloud_Front" {
  count = "${terraform.workspace}" == "prod" ? 1 : 0
  source = "../modules/Cloud_Front"
  domain = var.domain
  domain_zone_id = module.api_cert.zone_id
  s3_domain_name = module.S3_web_hosting.s3_domain_name
}


