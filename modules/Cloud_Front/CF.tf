#This module is for creating certification and cloud distribution of your domain
#and serve the content from s3 origin 

#######################
#request certificate for domain
######################

resource "aws_acm_certificate" "domain_cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#################
#validate domain certificate
################

#record validation options of the domain certificate on route 53 as we choose the validation method = "DNS"
resource "aws_route53_record" "record_options" {
  for_each = {
    for dvo in aws_acm_certificate.domain_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.domain_zone_id
}

#finally validate that records is recorded and validate the domain certificate
resource "aws_acm_certificate_validation" "dev_cert_validate" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record_options : record.fqdn]
}


#####################
#cloud distribution for domain
#####################

locals {
  S3_origin_id = "raffle_s3_origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = var.s3_domain_name
    origin_id                = local.S3_origin_id
  }

  enabled             = true
  comment             = "Some comment"
  default_root_object = "apply.html"


  aliases = [var.domain]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.S3_origin_id

    forwarded_values {
        query_string = false

        cookies {
        forward = "none"
        }
    }



    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "${terraform.workspace}"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.domain_cert.arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [ aws_acm_certificate_validation.dev_cert_validate ]

}


#create record to redirect ahmedsamy.link to alias of the cloud distribution
resource "aws_route53_record" "dev_CF_record" {
  zone_id = var.domain_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }

}
