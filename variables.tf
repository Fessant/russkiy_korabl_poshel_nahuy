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

variable "ami" {
  type = map(string)

  default = {
    "ap-east-1"    = "ami-02333d201cff78886"
    "eu-west-2"    = "ami-0cf5e24570c2b477b"
    "eu-central-1" = "ami-095e0f8062e0e8216"
  }
}

variable "aws_region" {
  default = "ap-east-1"
}

variable "instance_count" {
  default = "32"
}

variable "instance_type" {
  default = "t3.large"
}

variable "enable_logs" {
  type    = string
  default = false
}

variable "remote_links"{
  type = string
  default = "https://forukraine.s3.ap-east-1.amazonaws.com/links.txt"
}
