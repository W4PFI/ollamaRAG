#!/bin/sh

# Build the Docker image using your Dockerfile
docker build -t ollama-server .

# Run the Docker container with GPU support and mount the knowledge directory
docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 -p 8000:8000 --name ollama ollama-server

