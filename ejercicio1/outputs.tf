output "proxy_url" {
  description = "URL de acceso a la aplicación a través del proxy"
  value       = "http://localhost:${var.proxy_port}"
}

output "network_name" {
  description = "Nombre de la red Docker creada"
  value       = docker_network.iac_network.name
}
