#!/bin/bash

# Set server address from environment variable or use localhost as default
OLLAMA_SERVER_ADDRESS=${OLLAMA_SERVER_ADDRESS:-localhost}
OLLAMA_PORT=${OLLAMA_PORT:-8000}


# Use curl to send a POST request to unload all documents from the FastAPI server
RESPONSE=$(curl -s -X POST "http://$OLLAMA_SERVER_ADDRESS:$OLLAMA_PORT/unload")

# Check the response to confirm the unload action
if echo "$RESPONSE" | grep -q "successfully"; then
  echo "RAG model unloaded successfully."
else
  echo "Failed to unload RAG model. Response from server:"
  echo "$RESPONSE"
fi
