variable "invoke_arns" {
  description = "invoke arns for functions to be able to grantee the api permission to invoke them"
  type = list(any)
}

variable "function_name" {
  description = "you should write functions names that you want to create"
   type = list(any)
}

variable "route_key" {
  description = "this is the route key(defines method and path) for each function"
  type        = map(string)

  #key will be function name and value will be the route key
  default = {
    "apply" = "POST /"
    "count" = "GET /count"
    "draw" = "GET /draw"

  }
}

variable "api_url" {
  description = "the url of the api"
  type = string
}

variable "api_cert_arn" {
  description = "the certification arn for the api url to be able to create custom domain "
  type = string
}

variable "domain_zone_id" {
  description = "domain name zone id to be able to create record for custome domain on route53"
  type = string
}

variable "s3_url" {
  description = "s3 website endpoint to add it on allowed origin"
  type = string
}

variable "Cloud_Front_url" {
  description = "Cloud Front url to add it on allowed origin for production environment"
  type = string
}

variable "domain" {
   description = "Domain name"
   type = string
}
