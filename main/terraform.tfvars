#Write your registered domain
domain = "ahmedsamy.link"

#write the functions names
function_name = ["apply" , "count" , "draw"]

#write the code directory of functions  
functions_dev_directory = "../dev_code/functions"
functions_prod_directory = "../prod_code/functions"

#Write method and path for each function as key : value 
route_key =  {
    "apply" = "POST /"
    "count" = "GET /count"
    "draw" = "GET /draw"

  }

#write the html pages 
html_pages = [ "apply.html" , "count.html"]

#write the code directory of html pages
html_dev_directory = "../dev_code/html"
html_prod_directory = "../prod_code/html"