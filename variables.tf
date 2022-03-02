variable "pem_key_path" {
  description = "Here in default provide path to your .pem key. For example for windows - C:\\path\\to\\key\\aws_key.pem"
  default = "C:\\War\\aws_key.pem"
}

variable "attack_duration" {
  default = 3600
}
