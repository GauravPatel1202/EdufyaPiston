# Deploying EdufyaPiston

This guide covers how to deploy the Piston code execution engine to a server (VPS) or cloud environment.

## Prerequisites

- A Linux server (Ubuntu/Debian recommended).
- Root or sudo access.
- Git (optional, but recommended).

## Automatic Deployment (Recommended)

We provide a `deploy.sh` script that automates the setup of Docker, Git, and the Piston container.

1.  **Download the script** (if you haven't cloned the repo):

    ```bash
    curl -O https://raw.githubusercontent.com/GauravPatel1202/EdufyaPiston/main/deploy.sh
    chmod +x deploy.sh
    ```

2.  **Run the script**:
    ```bash
    ./deploy.sh
    ```

This script will:

- Update system packages.
- Install Docker and Docker Compose.
- Clone/Update the `EdufyaPiston` repository to `~/EdufyaPiston`.
- Build and start the Piston container on port `2000`.

## Manual Deployment

If you prefer to configure things manually:

1.  **Install Docker**: Follow the [official Docker installation guide](https://docs.docker.com/engine/install/).
2.  **Clone the Repository**:
    ```bash
    git clone https://github.com/GauravPatel1202/EdufyaPiston.git
    cd EdufyaPiston
    ```
3.  **Start Piston**:
    ```bash
    docker-compose up -d --build
    ```

## Verification

Once deployed, verify that Piston is running:

```bash
curl http://localhost:2000/api/v2/runtimes
```

You should see a JSON list of installed runtimes (Python, Node.js, etc.).
