variable "pem_key_path" {
  description = "Here in default provide path to your .pem key. For example for windows - C:\\path\\to\\key\\aws_key.pem"
  default     = "C:\\War\\aws_key.pem"
}

variable "attack_duration" {
  description = "Value in milliseconds. 3600 == 1 hour"
  default = 3600
}
variable "watch_repeat" {
  description = "Value in milliseconds. 1800 == 30 minutes"
  default = 1800
}
variable "shutdown_hour" {
  description = "Server will shutdown at particular time of day. 22 == will shutdown at 1 A.M. by moscow time (22:00 + 3:00 UTC == 1 A.M.)"
  default = 22
}

variable "enable_logs" {
  type    = string
  default = false
}

variable "remote_links"{
  type = string
  default = "https://forukraine.s3.ap-east-1.amazonaws.com/links.txt"
}
