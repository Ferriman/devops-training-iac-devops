variable "db_name" {
  type        = string
  description = "Nombre de la base de datos PostgreSQL"
}

variable "db_user" {
  type        = string
  description = "Usuario de la base de datos PostgreSQL"
}

variable "db_password" {
  type        = string
  description = "Contraseña de la base de datos PostgreSQL"
  sensitive   = true
}

variable "app_port" {
  type        = number
  description = "Puerto interno del servidor de aplicación"
  default     = 8080
}

variable "proxy_port" {
  type        = number
  description = "Puerto expuesto al host por el proxy Nginx"
  default     = 80
}
