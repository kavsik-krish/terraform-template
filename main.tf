
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = file("keys.json")
  project     = "abc"
}

resource "google_container_cluster" "default" {
  name     = "[cluster_name]"
  location = "us-central1"
  initial_node_count = 1
  node_config {
    machine_type = "e2-medium"
  }
  min_master_version = "1.19.10-gke.1000"
  master_auth {
    username = "admin"
  }
  network = "default"
  subnetwork = "projects/gcp-project-id/regions/us-central1/subnetworks/default"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "[service_name]"
  location = "us-central1"
  template {
    containers {
      image = "[container_image]"
      resources {
        limits {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }
}

resource "google_app_engine_application" "default" {
  location_id = "us-central1"
  name        = "[app_name]"
}

resource "google_app_engine_service" "default" {
  name     = "[service_name]"
  location = "us-central1"
  application = google_app_engine_application.default.name
  env = "standard"
  runtime = "nodejs16"
  scaling {
    max_instances = 1
  }
}

resource "google_cloudfunctions_function" "default" {
  name     = "[function_name]"
  runtime  = "nodejs16"
  entry_point = "helloHTTP"
  source_archive_bucket = "[bucket_name]"
  source_archive_object = "[object_name]"
  trigger_http = true
  region = "us-central1"
}

resource "google_compute_target_http_proxy" "default" {
  name = "[http_proxy_name]"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name    = "[url_map_name]"
  default_service = google_compute_backend_service.default.id
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_service.default.id
  }
}

resource "google_compute_backend_service" "default" {
  name = "[backend_service_name]"
  port_name = "http"
  protocol = "HTTP"
  timeout_sec = 10
  health_checks = [google_compute_health_check.default.id]
  load_balancing_scheme = "INTERNAL"
}

resource "google_compute_health_check" "default" {
  name = "[health_check_name]"
  check_interval_sec = 5
  timeout_sec = 5
  healthy_threshold = 2
  unhealthy_threshold = 2
  http_health_check {
    port = 80
    request_path = "/"
  }
}
