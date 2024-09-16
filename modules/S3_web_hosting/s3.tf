#This module is for creating s3 bucket bucket with name of your domain
#and enable s3 web hosting and upload the html pages for your app


############
#create bucket and allow public access for it
############

locals {
  url = terraform.workspace == "prod" ? "${var.domain}" : "${terraform.workspace}.${var.domain}"
}
#create s3 bucket 
resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.url

  tags = {
    Name        = "${terraform.workspace}_s3_bucket"
    Environment = "${terraform.workspace}"
  }
}

#allow public access for the bucket
resource "aws_s3_bucket_public_access_block" "s3_allow_pub_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#allow any one to access bucket objects
resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
  depends_on = [ aws_s3_bucket_public_access_block.s3_allow_pub_access ]
}


################
#upload html pages
################

#decide the working directory depending on the environment
locals {
  html_working_directories = {
    "dev" : var.html_dev_directory
    "prod" : var.html_prod_directory
  }
  html_work_directory = lookup(local.html_working_directories , "${terraform.workspace}" , "html working directory of this environment is not found " )
}

#upload html pages as an object
resource "aws_s3_object" "page" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = var.html_pages[count.index]
  content_type = "text/html"
  source = "${local.html_work_directory}/${var.html_pages[count.index]}"
  cache_control = "no-cache"
  depends_on = [ aws_s3_bucket_website_configuration.web_hosting ]
  count = length(var.html_pages)
  tags = {
    Environment = "${terraform.workspace}"
  }
}

#################
#enable s3 web hosting
#################

resource "aws_s3_bucket_website_configuration" "web_hosting" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "apply.html"
  }
}

