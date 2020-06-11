terraform {
  required_varsion = "0.11.14"
}

provider "google" {
  version = "2.0.0"

  # Project id
  project = "keen-ripsaw-278820"
  project = "${var.project}"

  #region = "europe-west1"
  region = "${var.region}"
}

resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)} ivanmazur:${file(var.public_key_path)}"
  }
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  metadata {
    ssh-keys = "ivanmazur:${file(var.public_key_path)}"
  }

  # network_interface {
  #   network       = "default"
  #   access_config {}
  # }

  connection {
    type        = "ssh"
    user        = "ivanmazur"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  network_interface {
    network = "default"
    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Name of the natwork in which the rule applies
  network = "default"

  # What access to allow
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # What addresses are allowed access
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "google_compute_firewall" "firewall_ssh" {
  name = "default-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
