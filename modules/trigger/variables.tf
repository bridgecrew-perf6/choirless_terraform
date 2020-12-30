variable "bucket" {}

variable "lambda" {}

variable "events" {
  default = ["s3:ObjectCreated:*","s3:ObjectDeleted:*"]
}
