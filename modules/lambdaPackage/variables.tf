variable "filename" {}

variable "runtime" {
  default = "nodejs12.x"
}

variable "timeout" {
  default = 10
}

variable "env_variables" {
  default = {}
}

variable "role" {
}

variable "layers" {
  default = []
}

variable "tags" {
}
