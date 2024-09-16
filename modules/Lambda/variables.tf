variable "function_name" {
    description = "you should write functions names that you want to create"
    type = list(any)
    default = [ "apply" , "count" , "draw" ]

}

variable "functions_prod_directory" {
    description = "you should write functions directory"
    type = string
    

}
variable "functions_dev_directory" {
    description = "you should write functions directory"
    type = string
    
}

variable "lambda_role_arn" {
    description = "this is the role which attache to the function to grantee it access to DynamoDB"
    type = string
}