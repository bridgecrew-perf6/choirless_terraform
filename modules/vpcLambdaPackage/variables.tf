variable "filename" {}

variable "runtime" {
  default = "nodejs12.x"
}

variable "timeout" {
  default = 10
}

variable "memory_size" {
  default = 128
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

variable "efs_access_point" {

}

variable "local_mount_path" {

}

variable "subnet_ids" {
  default = []
}

variable "security_group_ids" {
  default = []
}

