variable "project_name" {
  type        = string
  description = "Nombre base del proyecto"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "Tamaño de la máquina virtual"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Usuario administrador de la VM"
}

variable "ssh_public_key" {
  type        = string
  description = "Clave pública SSH para acceso a la VM"
}
