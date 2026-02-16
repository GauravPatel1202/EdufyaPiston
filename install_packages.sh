#!/bin/bash

# Ensure we are in the EdufyaPiston directory
set -e
cd "$(dirname "$0")"

echo "Installing CLI dependencies..."
cd cli
npm install
cd ..

echo "Installing language runtimes using Piston CLI..."

# Node.js
node cli/index.js ppman install node

# Python
node cli/index.js ppman install python

# Java
node cli/index.js ppman install java

# C++ (gcc)
node cli/index.js ppman install gcc

# Go
node cli/index.js ppman install go

# .NET (dotnet)
node cli/index.js ppman install dotnet

# Kotlin
node cli/index.js ppman install kotlin

echo "Installation complete!"
