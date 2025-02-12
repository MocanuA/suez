variable "ovh_application_key" {
  type = string
}

variable "ovh_application_secret" {
  type = string
}

variable "ovh_consumer_key" {
  type = string
}

variable "vps_ip" {
  type = string
}

variable "ssh_user" {
  type = string
  default = "ubuntu"
}

variable "ssh_password" {
  type = string
}
