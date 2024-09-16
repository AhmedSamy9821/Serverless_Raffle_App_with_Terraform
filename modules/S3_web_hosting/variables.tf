variable "domain" {
  description = "domain name because the bucket name should be as the domain name"
  type = string
}

variable "html_pages" {
  description = "list of html pages that will uploaded to s3 bucket"
  type = list(string)
}

variable "html_dev_directory" {
  description = "directory of dev environment html pages"
  type = string
}

variable "html_prod_directory" {
  description = "directory of production environment html pages"
  type = string
}