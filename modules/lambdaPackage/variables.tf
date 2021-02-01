variable "filename" {}

variable "runtime" {
  default = "python3.8"

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
