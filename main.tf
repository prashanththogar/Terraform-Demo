// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.serviceaccount}")}"
 project     = "${var.gcp_project}" 
 region      = "${var.region}"
}

// Create VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.name}-vpc"
 auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "subnet" {
 name          = "${var.name}-subnet"
 ip_cidr_range = "${var.subnet_cidr}"
 network       = "${var.name}-vpc"
 depends_on    = ["google_compute_network.vpc"]
 region      = "${var.region}"
}

// VPC firewall configuration
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.name}-fw-allow-internal"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow-http" {
  name    = "${var.name}-fw-allow-http"
  network = "${google_compute_network.vpc.name}"
allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 
}
resource "google_compute_firewall" "allow-bastion" {
  name    = "${var.name}-fw-allow-bastion"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
  }

//Create Compute Instance
resource "google_compute_instance" "default" {
  name         = "${format("%s","${var.name}-${var.env}-${var.region}}-instance1")}"
  machine_type = "n1-standard-1"
  zone         = "${format("%s","${var.region_zone}")}"
  tags         = ["ssh","http"]
  boot_disk {
    initialize_params {
      image     =  "debian-cloud/debian-9"     
    }
  }
labels {
      webserver =  "true"     
    }
network_interface {
    network = "${google_compute_network.vpc.self_link}"
    access_config = {
    }
  }

metadata_startup_script = data.template_file.nginx.rendered

data "template_file" "nginx" {
#  template = "${file("${var.gcs_bucket}/template/install_nginx.tpl")}"
template = "template/install_nginx.tpl"

  vars = {
    ufw_allow_nginx = "Nginx HTTP"
  }
}
