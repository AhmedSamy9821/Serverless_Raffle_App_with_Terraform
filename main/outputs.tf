#S3 website endpoint
output "s3_url" {
  value = "http://${module.S3_web_hosting.s3_url}"
}

#Web site url
locals {
  websit_url = {
    "prod" : "https://${var.domain}"
    "dev" : "http://${terraform.workspace}.${var.domain}"
  }
}
output "Your_website_url" {
  value = lookup(local.websit_url , "${terraform.workspace}" , "there is no url for this environment")
}
