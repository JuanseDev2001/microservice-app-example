#!/bin/bash

# Script to deploy microservices to the VM
VM_IP="52.186.51.57"
REPO_URL="https://github.com/JuanseDev2001/microservice-app-example.git"

echo "Deploying microservices to VM at $VM_IP"

# SSH into the VM and execute deployment commands
ssh -o StrictHostKeyChecking=no azureuser@$VM_IP << 'EOF'
    echo "Starting deployment process..."
    
    # Clone the repository if it doesn't exist
    if [ ! -d "/home/azureuser/microservice-app" ]; then
        echo "Cloning repository..."
        git clone https://github.com/JuanseDev2001/microservice-app-example.git /home/azureuser/microservice-app
    else
        echo "Repository already exists, pulling latest changes..."
        cd /home/azureuser/microservice-app
        git pull origin main
    fi
    
    cd /home/azureuser/microservice-app
    
    # Install Docker if not already installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker azureuser
    fi
    
    # Wait for docker group to take effect
    newgrp docker << 'DOCKER_COMMANDS'
        echo "Starting microservices with Docker Compose..."
        docker-compose down || echo "No existing containers to stop"
        docker-compose up -d
        
        echo "Waiting for services to start..."
        sleep 30
        
        echo "Checking running containers:"
        docker-compose ps
        
        echo "Services should be available at:"
        echo "Frontend: http://52.186.51.57:9083"
        echo "Auth API: http://52.186.51.57:9080"
        echo "Users API: http://52.186.51.57:9081"
        echo "Todos API: http://52.186.51.57:9082"
DOCKER_COMMANDS
    
    echo "Deployment completed!"
EOF