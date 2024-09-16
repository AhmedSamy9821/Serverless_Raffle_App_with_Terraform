#This module is for creating dynamoDB table to register the users 

resource "aws_dynamodb_table" "register-table" {
  name         = "${terraform.workspace}-register-table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "email"
    type = "S"
  }

  hash_key = "email"

  tags = {
    Name        = "${terraform.workspace} register Table"
    Environment = "${terraform.workspace}"
  }
}
