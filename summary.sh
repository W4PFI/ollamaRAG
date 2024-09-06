#!/bin/bash

# Set server address from environment variable or use localhost as default
OLLAMA_SERVER_ADDRESS=${OLLAMA_SERVER_ADDRESS:-localhost}
OLLAMA_PORT=${OLLAMA_PORT:-8000}

# Check if a filename is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: ./summary.sh <filename>"
  exit 1
fi

# Set the filename from the argument
FILENAME="$1"

# Check if the file exists
if [ ! -f "$FILENAME" ]; then
  echo "File not found: $FILENAME"
  exit 1
fi

# Read the content of the file and escape special characters
FILE_CONTENT=$(<"$FILENAME")
ESCAPED_CONTENT=$(jq -Rsa <<< "$FILE_CONTENT")

# Use curl to send a POST request to summarize the document content via the FastAPI server
curl -X POST "http://$OLLAMA_SERVER_ADDRESS:$OLLAMA_PORT/summarize" -H "Content-Type: application/json" -d "{\"content\": $ESCAPED_CONTENT}"

echo -e "\nSummary of the file: $FILENAME"
