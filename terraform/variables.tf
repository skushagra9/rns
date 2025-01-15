variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region to create resources in"
  default     = "us-central1"
}

variable "db_instance_name" {
  type        = string
  description = "Name of the Cloud SQL instance"
  default     = "node-ps-app-db"
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "node-ps-app"
}

variable "db_user" {
  type        = string
  description = "Database user"
  default     = "node-user"
}

variable "db_password" {
  type        = string
  description = "Database user password"
  sensitive   = true
  default     = "node-user-password"
}

variable "cloud_run_service_name" {
  type        = string
  description = "Name of the Cloud Run service"
  default     = "node-ps-app-service"
}

variable "container_image" {
  type        = string
  description = "container image (e.g. us-docker.pkg.dev/PROJECT_ID/REPO/IMAGE:tag)"
  default     = "testnetfilament/node-ps-app:latest2"
}

variable "use_https" {
  type        = bool
  description = "Whether to use HTTPS or just HTTP"
  default     = false
}

