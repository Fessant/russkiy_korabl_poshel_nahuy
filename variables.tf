variable "pem_key_path" {
  description = "Here in default provide path to your .pem key. For example for windows - C:\\path\\to\\key\\aws_key.pem"
  default     = "C:\\War\\aws_key.pem"
}

variable "attack_duration" {
  default = 3600
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
  default = "16"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "enable_logs" {
  type    = string
  default = false
}

variable "remote_links"{
  type = string
  default = "https://forukraine.s3.ap-east-1.amazonaws.com/links.txt"
}
