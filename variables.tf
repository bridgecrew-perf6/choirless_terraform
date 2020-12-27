variable "COUCH_URL" {
  description = "URL to access couchdb"
  type        = string
  sensitive  = true
}

variable "tags" {
  description = "Tags for the project"
  type        = map(string)
}

#variable "api_methods" {
#  default = [ "user:GET:getUser", "user/byemail:GET:getUserByEmail" ]
#}

#variable "api_methods" {
#  default = [
#    {
#      path_part = "user"
#      method    = "GET"
#      lambda = "getUser"
#    },
#    {
#     path_part = "user/byemail"
#    method    = "GET"
#    lambda = "getUserByEmail"
#  }
#  ]
#}
