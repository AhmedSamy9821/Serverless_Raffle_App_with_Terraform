
#Out S3 website end point to pass it to api_gatway module to put it in allowed origins
output "s3_url" {
  value = aws_s3_bucket_website_configuration.web_hosting.website_endpoint
}

#Out S3 website domain to use it in creating record that redirect dev environment url to the s3 website
output "s3_website_domain" {
  value = aws_s3_bucket_website_configuration.web_hosting.website_domain
}

#Out S3 hosted zone id to use it in creating record that redirect dev environment url to the s3 website
output "s3_zone_id" {
  value = aws_s3_bucket.s3_bucket.hosted_zone_id
  
}

#Out the bucket domain name of s3 bucket to use it as origin for the cloud disribution
output "s3_domain_name" {
  value = aws_s3_bucket.s3_bucket.bucket_domain_name
  
}