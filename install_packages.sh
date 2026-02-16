#!/bin/bash
set -e

echo "Installing language runtimes using Piston API..."

# Helper to install package
install_package() {
    LANG=$1
    echo "Installing $LANG..."
    node -e "
    const http = require('http');
    const data = JSON.stringify({ language: '$LANG', version: '*' });
    const options = {
        hostname: 'localhost',
        port: 2000,
        path: '/api/v2/packages',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': data.length
        }
    };
    const req = http.request(options, res => {
        if (res.statusCode !== 200) {
            console.error('Failed to install $LANG: Status ' + res.statusCode);
            process.exit(1);
        }
        res.pipe(process.stdout);
    });
    req.on('error', error => {
        console.error('Error installing $LANG:', error);
        process.exit(1);
    });
    req.write(data);
    req.end();
    "
    echo ""
}

# Install Languages
install_package "node"
install_package "python"
install_package "java"
install_package "gcc"
install_package "go"
install_package "dotnet"
install_package "kotlin"

echo "Installation complete!"
