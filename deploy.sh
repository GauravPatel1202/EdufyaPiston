#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Piston Deployment on VPS...${NC}"

# 1. Update System
echo -e "${GREEN}[1/5] Updating system packages...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

# 2. Install Dependencies (Docker, Git, etc.)
echo -e "${GREEN}[2/5] Installing Docker and Git...${NC}"
if ! command -v docker &> /dev/null; then
    sudo apt-get install -y ca-certificates curl gnupg lsb-release git
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
    echo "Docker already installed."
fi

# 3. Setup Piston Directory
echo -e "${GREEN}[3/5] Setting up Piston directory...${NC}"
DEPLOY_DIR="$HOME/EdufyaPiston"

if [ -d "$DEPLOY_DIR" ]; then
    echo "Directory exists. Pulling latest changes..."
    cd "$DEPLOY_DIR"
    # Check if it's a git repo
    if [ -d ".git" ]; then
        git pull origin main || echo "Git pull failed. You might need to update manually."
    else
        echo "Not a git repository. Skipping pull."
    fi
else
    echo "Cloning repository..."
    # Cloning public/private repo. If private, requires SSH keys or simple HTTPS auth
    # For now, we assume the user might have to clone manually if auth is needed, 
    # but we provides the command.
    git clone https://github.com/GauravPatel1202/EdufyaPiston.git "$DEPLOY_DIR" || {
        echo "Clone failed. Please ensure you have access rights."
        echo "Creating directory manually for you to upload files..."
        mkdir -p "$DEPLOY_DIR"
    }
    cd "$DEPLOY_DIR"
fi

# 4. Build and Run Container
echo -e "${GREEN}[4/5] Building and Running Piston container...${NC}"
# Use the docker-compose plugin
sudo docker compose down || true # Remove old containers
sudo docker compose up -d --build

# 5. Verification
echo -e "${GREEN}[5/5] Deployment Complete!${NC}"
echo "Waiting for service to start..."
sleep 5
if curl -s http://localhost:2000/api/v2/runtimes > /dev/null; then
    echo -e "${GREEN}Success! Piston is running on port 2000.${NC}"
    echo "Public URL: http://$(curl -s ifconfig.me):2000"
else
    echo "Service check failed. Please check logs with: 'sudo docker compose logs -f'"
fi
