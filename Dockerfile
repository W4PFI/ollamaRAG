# Use the official Python slim image as a base
FROM python:3.10-slim

# Install necessary dependencies for Ollama
RUN apt-get update && apt-get install -y curl

# Install Ollama CLI (modify with the correct installation command if necessary)
RUN curl -s https://ollama.com/install.sh | bash

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file first
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy OllamaServer.py to the root directory in the container
COPY OllamaServer.py /root/OllamaServer.py

# Set the PYTHONPATH environment variable
ENV PYTHONPATH=/root

# Expose the necessary port for FastAPI
EXPOSE 8000

# Command to start both the Ollama server and the FastAPI server
CMD ["bash", "-c", "ollama serve & uvicorn OllamaServer:app --host 0.0.0.0 --port 8000"]