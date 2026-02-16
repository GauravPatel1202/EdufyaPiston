#!/bin/bash
set -e

# CLI is assumed to be at /piston/cli/index.js in the Docker image
CLI="/piston/cli/index.js"

echo "Installing language runtimes using Piston CLI..."

# Node.js
node $CLI ppman install node


# Python
node $CLI ppman install python

# Java
node $CLI ppman install java

# C++ (gcc)
node $CLI ppman install gcc

# Go
node $CLI ppman install go

# .NET (dotnet)
node $CLI ppman install dotnet

# Kotlin
node $CLI ppman install kotlin

echo "Installation complete!"
