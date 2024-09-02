#!/bin/sh

# Pull the Ollama Docker image
docker pull ollama/ollama

# Run the Docker container with GPU support and mount the knowledge directory
docker run -d --gpus=all -v ollama:/root/.ollama -v ~/knowledge:/knowledge -p 11434:11434 -p 8000:8000 --name ollama ollama/ollama

# Wait for a few seconds to ensure the Docker container is up and running
sleep 10

# Install Python and pip inside the container
docker exec ollama apt-get update
docker exec ollama apt-get install -y python3 python3-pip

# Install Python libraries inside the container
docker exec ollama pip3 install -U langchain ollama faiss-gpu sentence-transformers langchain-community fastapi uvicorn

# Copy the updated Python script (OllamaServer.py) into the Docker container
docker cp ./OllamaServer.py ollama:/root/OllamaServer.py

# Run the FastAPI server inside the Docker container
docker exec -d ollama /bin/bash -c "export PYTHONPATH=/root && uvicorn OllamaServer:app --host 0.0.0.0 --port 8000"

