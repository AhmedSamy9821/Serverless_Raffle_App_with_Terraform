#Out the Cloud Front url to add it on allowed origin on API_gateway module for production environment
output "Cloud_Front_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}