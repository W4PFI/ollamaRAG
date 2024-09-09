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

# Read the content of the file and escape special characters for JSON compatibility
FILE_CONTENT=$(<"$FILENAME")
ESCAPED_CONTENT=$(jq -Rs <<< "$FILE_CONTENT")

# Use curl to send a POST request to summarize the document content via the FastAPI server
RESPONSE=$(curl -s -X POST "http://$OLLAMA_SERVER_ADDRESS:$OLLAMA_PORT/summarize" \
  -H "Content-Type: application/json" \
  -d "{\"content\": $ESCAPED_CONTENT}")

# Check if curl command was successful
if [ $? -ne 0 ]; then
  echo "Error: Unable to connect to the summarization server."
  exit 1
fi

# Use jq to extract and clean the bullet points from the JSON response
SUMMARY=$(echo "$RESPONSE" | jq -r '.bullet_points')

# Check if the summary is empty
if [ -z "$SUMMARY" ]; then
  echo "No summary available."
  exit 1
fi

# Output the cleaned-up summary to the console (removing JSON structure)
echo -e "\nSummary of the file: $FILENAME"
echo -e "$SUMMARY"

# Optionally, write the summary to a text file (change extension as needed)
#SUMMARY_FILENAME="${FILENAME%.txt}_summary.txt"
#echo -e "$SUMMARY" > "$SUMMARY_FILENAME"

# Inform the user that the summary was saved
#echo "Summary saved to: $SUMMARY_FILENAME"
