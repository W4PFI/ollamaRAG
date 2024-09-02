#!/bin/bash

# Use curl to send a POST request to unload all documents from the FastAPI server
RESPONSE=$(curl -s -X POST "http://localhost:8000/unload")

# Check the response to confirm the unload action
if echo "$RESPONSE" | grep -q "successfully"; then
  echo "RAG model unloaded successfully."
else
  echo "Failed to unload RAG model. Response from server:"
  echo "$RESPONSE"
fi
