##############
#API_cert module variables
###############
variable "domain" {
  description = "domain name"
  type        = string
}

###############
#Lambda module variables
###############

#You should write the functions names on list on this variable
variable "function_name" {
    description = "you should write functions names that you want to create"
    type = list(string)
}

#You should write the functions directory on this variable
variable "functions_prod_directory" {
    description = "you should write functions production directory"
    type = string
}

variable "functions_dev_directory" {
    description = "you should write functions dev directory"
    type = string
}

###################
#API_gatway module variables
###################
variable "route_key" {
    description = "this is the route key for each function"
    type = map(string)
}

#############
#S3 module variables
############
variable "html_pages" {
  description = "list of html pages that will uploaded to s3 bucket "
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

