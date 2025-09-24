output "public_ip_address" {
  description = "Dirección IP pública de la VM"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "frontend_url" {
  description = "URL para acceder al frontend"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:9083"
}

output "auth_api_url" {
  description = "URL para acceder al Auth API"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:9080"
}

output "users_api_url" {
  description = "URL para acceder al Users API"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:9081"
}

output "todos_api_url" {
  description = "URL para acceder al Todos API"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:9082"
}

output "ssh_connection" {
  description = "Comando SSH para conectarse a la VM"
  value       = "ssh azureuser@${azurerm_public_ip.public_ip.ip_address}"
}