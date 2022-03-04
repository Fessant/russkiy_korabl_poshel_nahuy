variable "pem_key_path" {
  description = "Here in default provide path to your .pem key. For example for windows - C:\\path\\to\\key\\aws_key.pem"
  default     = "C:\\War\\aws_key.pem"
}

variable "attack_duration" {
  default = 3600
}

variable "enable_logs" {
  type    = string
  default = false
}

variable "remote_links"{
  type = string
  default = "https://dieputindie.s3.eu-north-1.amazonaws.com/links.txt"
}
