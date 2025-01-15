#######################################
# 1. Create a Cloud SQL PostgreSQL DB #
#######################################

resource "google_sql_database_instance" "db_instance" {
  name             = var.db_instance_name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-g1-small"
  }
}

resource "google_sql_database" "db" {
  name     = var.db_name
  instance = google_sql_database_instance.db_instance.name
  project  = var.project_id
}

resource "google_sql_user" "db_user" {
  name     = var.db_user
  password = var.db_password
  instance = google_sql_database_instance.db_instance.name
  project  = var.project_id
}

########################################
# 2. Deploy a Cloud Run service        #
########################################

resource "google_cloud_run_service" "service" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    
    spec {
      containers {
        image = var.container_image

        env {
             name="DB_URL"
             value = "postgresql://${var.db_user}:${var.db_password}@/${var.db_name}?host=/cloudsql/${google_sql_database_instance.db_instance.connection_name}"
            
        }
      }
        
    }
     metadata {
            annotations = {
                "run.googleapis.com/cloudsql-instances"=google_sql_database_instance.db_instance.connection_name
            }
        }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = var.region
  project  = var.project_id
  service  = google_cloud_run_service.service.name

  policy_data = data.google_iam_policy.cloud_run_noauth.policy_data
}

data "google_iam_policy" "cloud_run_noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

########################################
# 3. Create a Serverless NEG & Backend #
########################################

resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = "${var.cloud_run_service_name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.service.name
  }
}

resource "google_compute_backend_service" "cloud_run_backend" {
  name                  = "${var.cloud_run_service_name}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30
  connection_draining_timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }
}

# URL Map: Defines routing rules
resource "google_compute_url_map" "cloud_run_url_map" {
  name            = "${var.cloud_run_service_name}-url-map"
  default_service = google_compute_backend_service.cloud_run_backend.self_link
}

# Target HTTP Proxy: Handles HTTP traffic
resource "google_compute_target_http_proxy" "cloud_run_http_proxy" {
  name    = "${var.cloud_run_service_name}-http-proxy"
  url_map = google_compute_url_map.cloud_run_url_map.self_link
}

# Global Forwarding Rule: Routes external traffic to Target HTTP Proxy
resource "google_compute_global_forwarding_rule" "cloud_run_forwarding_rule" {
  name                = "${var.cloud_run_service_name}-forwarding-rule"
  target              = google_compute_target_http_proxy.cloud_run_http_proxy.self_link
  port_range          = "80"
  load_balancing_scheme = "EXTERNAL"
}
