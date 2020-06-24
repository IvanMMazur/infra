variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable "machine_type" {
  default     = "g1-small"
  description = "Machine type for reddit app instance"
}

variable "ssh_user" {
  default     = "ivanmazur"
  description = "SSH user name"
}

variable "db_internal_address" {
  description = "MongoDB internal IP"
  default     = "127.0.0.1"
}
