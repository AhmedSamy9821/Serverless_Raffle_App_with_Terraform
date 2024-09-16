#This module for creating HTTP API gateway and integrate it with lambda functions

#This logic is to decide what is allowed origin depending on the environment
locals {
  origins ={
  "dev" : ["http://${var.s3_url}" , "http://${terraform.workspace}.${var.domain}"]
  "prod" : ["http://${var.s3_url}" , "https://${var.Cloud_Front_url}" , "https://${var.domain}" ]
  }
}

##############
#create api and auto-deployed stage
##############

#create HTTP API gataway and set the allowed origin according to the environment
resource "aws_apigatewayv2_api" "raffle_api" {
  name          = "${terraform.workspace}_raffle_api"
  protocol_type = "HTTP"

  # CORS Configuration Block
  cors_configuration {
    allow_origins = lookup(local.origins , "${terraform.workspace}" , "") # Allow specific origin
    allow_methods = ["*"]  # HTTP methods allowed
    allow_headers = ["*"]  # Headers allowed
    expose_headers = ["*"]
    max_age = 3600  # Max age for browser to cache the preflight response
  }

  tags = {
    Environment = "${terraform.workspace}"
  }
}

#create default stage and make this stage is auto-deployed
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.raffle_api.id
  name        = "$default"   
  auto_deploy = true         # Enable auto-deploy
}


###################
#integration the API with lambda functions
###################

#intergrate with functions 
resource "aws_apigatewayv2_integration" "function_integration" {
    api_id           = aws_apigatewayv2_api.raffle_api.id
    integration_type = "AWS_PROXY"
    integration_uri  = var.invoke_arns[count.index]
    payload_format_version = "2.0"

    #create integration as long as number of functions
    count = length(var.invoke_arns)
}

#create lambda permission allows the API Gateway to call the functions
resource "aws_lambda_permission" "allow_call" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = "${terraform.workspace}_${var.function_name[count.index]}_function"
    principal     = "apigateway.amazonaws.com"

    #Source ARN allows invocation only from this specific API Gateway and stage
    source_arn = "${aws_apigatewayv2_api.raffle_api.execution_arn}/*/*"

    #create permission as long as number of functions
    count = length(var.function_name)
}

#create route for each function
resource "aws_apigatewayv2_route" "function_routes" {
  api_id    = aws_apigatewayv2_api.raffle_api.id
  route_key = lookup(var.route_key, var.function_name[count.index] , "GET /error")

  target = "integrations/${aws_apigatewayv2_integration.function_integration[count.index].id}"

  count = length(var.function_name)
}


####################
#create custom domain and Associate it with stage and API
####################

#create custom domain
resource "aws_apigatewayv2_domain_name" "api_domain" {
  domain_name = var.api_url

  domain_name_configuration {
    certificate_arn = var.api_cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
    
  }

  tags = {
    Environment = "${terraform.workspace}"
  }
}

#record the domain on route 53 and redirect its traffic to the api
resource "aws_route53_record" "api_record" {
  name    = aws_apigatewayv2_domain_name.api_domain.domain_name
  type    = "A"
  zone_id = var.domain_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

#mapping domain to the raffle api and stage
resource "aws_apigatewayv2_api_mapping" "raffle_api_mapping" {
  api_id      = aws_apigatewayv2_api.raffle_api.id
  domain_name = aws_apigatewayv2_domain_name.api_domain.id
  stage       = aws_apigatewayv2_stage.default_stage.id
}

