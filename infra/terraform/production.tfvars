# Production environment variables for Terraform

# Virtual Machine Configuration
vm_size        = "Standard_B4ms"  # Larger VM for production
admin_username = "azureuser"

# SSH Configuration - Replace with your actual SSH public key
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7eWnTqGqMTAEp89Q5FjM1HDLgJFMFqcHDdM+xFm4eghp+rHgXTqZyVQC3RWnD4BmkF98q3EQ5F3N2VjfMWXP3g3bN2Jm0FjH3vNkA9Bp0C8C3vLrQ4V3yjHx1FjZp8p4FnXgF5N9X0n2FzLsA6J7oUFM1k8q1TcXwF9V6KzPcFv9E9Z7VgN8ZxFjH9V0e9T2XzLqA3kF7U4G2EwT8CzL9e6H5xP0VfG4UgF9R8J3H5aP2KzX8Q4M6wJ9xVkQaM your-email@example.com"

# Network Configuration
location = "East US"

# Resource naming
resource_group_name = "microapp-production-rg"
vm_name            = "microapp-production-vm"

# Tags
environment = "production"
project     = "microservice-app"
