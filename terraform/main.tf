provider "google" {
  version = "2.0.0"

  # Project id
  #project = "hamster-2020"
  project = "${var.project}"

  #region = "europe-west1"
  region = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west1-b"

  tags = ["reddit-app"]

  metadata {
    #sshKeys = "ivanmazur:${file("~/.ssh/ivanmazur.pub")}"
    sshKeys = "ivanmazur:${file(var.public_key_path)}"
  }

  # Boot disk definition
  boot_disk {
    initialize_params {
      #image = "reddit-base-1589735657"
      image = "${var.disk_image}"
    }
  }

  # Network interface definition
  network_interface {
    # Network to which this interface is connected
    network = "default"

    # Use ephemeral IP to access from the internet
    access_config {}
  }

  connection {
    type  = "ssh"
    user  = "ivanmazur"
    agent = false

    # Private key path
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
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

  # The rule applies to instances with the listed tags
  target_tags = ["reddit-app"]
}
