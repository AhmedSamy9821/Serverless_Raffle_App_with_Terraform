#The purpose of this module is to create role for lambda function and grantee this role access to DynamoDB
# to be able to register the users on DynamoDB table

resource "aws_iam_role" "lambda-role" {
  name = "${terraform.workspace}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Environment = "${terraform.workspace}"
  }
}

#Attach dynamoDB full access policy to iam role
resource "aws_iam_role_policy_attachment" "dynamoDB-full-access-Attachment" {
  role       = aws_iam_role.lambda-role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
