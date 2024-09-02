#!/bin/bash

# Check if a filename is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: ./addDoc.sh <filename>"
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

# Use curl to send a POST request to load the document content into the FastAPI server
curl -X POST "http://localhost:8000/load" -H "Content-Type: application/json" -d "{\"content\": $ESCAPED_CONTENT}"

echo -e "\nDocument loaded from file: $FILENAME"
