resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  network_interface {
    network       = "default"
    access_config = {}
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name = "allow-mongo-default"

  # Name of the natwork in which the rule applies
  network = "default"

  # What access to allow
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  # What addresses are allowed access
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
