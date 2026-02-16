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

# Remove conflicting old packages if they exist
echo "Removing old Docker versions..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y || true; done

# Install using official convenience script for robustness
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    # Add current user to docker group to avoid sudo
    sudo usermod -aG docker $USER || true
    echo "Docker installed successfully."
else
    echo "Docker already installed."
fi

# 3. Setup Piston Directory
echo -e "${GREEN}[3/5] Setting up Piston directory...${NC}"
DEPLOY_DIR="$HOME/EdufyaPiston"

if [ -d "$DEPLOY_DIR" ]; then
    echo "Directory $DEPLOY_DIR exists."
    cd "$DEPLOY_DIR"
    if [ -d ".git" ]; then
        echo "Pulling latest changes..."
        git pull origin main || echo "Git pull failed. Proceeding with existing files."
    else
        echo "Not a git repository. Proceeding with existing files."
    fi
else
    echo "Directory not found. Cloning repository..."
    # Replace with your actual repository URL
    REPO_URL="https://github.com/GauravPatel1202/EdufyaPiston.git"
    
    git clone "$REPO_URL" "$DEPLOY_DIR" || {
        echo -e "${RED}Clone failed!${NC}"
        echo "Please manually create $DEPLOY_DIR and upload the files."
        exit 1
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
