provider "aws" {
  shared_config_files      = ["C:/Users/modeso/.aws/config"]
  shared_credentials_files = ["C:/Users/modeso/.aws/credentials"]
  profile                  = "terraform-cred"
}
#archive provider to be able to converts code files from js file to zip file
#to be able to identifyable for lambda function
provider "archive" {
}