# provider "google" {
#   version = "2.0.0"

#   # Project id
#   #project = "hamster-2020"
#   project = "${var.project}"

#   #region = "europe-west1"
#   region = "${var.region}"
# }

# resource "google_compute_firewall" "firewall_ssh" {
#   name = "default-allow-ssh"

#   # Name of the natwork in which the rule applies
#   network = "default"

#   # What access to allow
#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   # What addresses are allowed access
#   source_ranges = ["0.0.0.0/0"]
# }

# resource "google_compute_address" "app_ip" {
#   name = "reddit-app-ip"
# }

# resource "google_compute_instance" "app" {
  
# }
