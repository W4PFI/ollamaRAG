#!/bin/bash

# Set server address from environment variable or use localhost as default
OLLAMA_SERVER_ADDRESS=${OLLAMA_SERVER_ADDRESS:-localhost}
OLLAMA_PORT=${OLLAMA_PORT:-8000}

# Function to print text in green
print_green() {
  echo -e "\033[0;32m$1\033[0m"
}

# Function to print text in white
print_white() {
  echo -e "\033[1;37m$1\033[0m"
}

# Check if interactive mode is specified
if [ "$1" == "-interactive" ]; then
  echo "Entering interactive mode. Type 'exit' to quit."

  while true; do
    # Prompt user for a question
    print_white "Your question:"
    read QUESTION
    
    # Check if the user wants to exit
    if [ "$QUESTION" == "exit" ]; then
      echo "Exiting interactive mode."
      break
    fi

    # Send the question to the FastAPI server
    RESPONSE=$(curl -s -X POST "http://$OLLAMA_SERVER_ADDRESS:$OLLAMA_PORT/query" -H "Content-Type: application/json" -d "{\"question\": \"$QUESTION\"}")

    # Extract the answer from the JSON response using jq
    ANSWER=$(echo "$RESPONSE" | jq -r '.answer')

    # Check if jq failed to parse the answer
    if [ "$ANSWER" == "null" ]; then
      echo "Failed to parse response. Please check if the server is running and the endpoint is correct."
    else
      # Print the answer in green text
      print_green "$ANSWER"
    fi
  done
else
  # Check if a question is provided as an argument
  if [ -z "$1" ]; then
    echo "Usage: ./qa.sh <question> or ./qa.sh -interactive"
    exit 1
  fi

  # Combine all arguments into a single question string
  QUESTION="$*"

  # Use curl to send a POST request to query the content from the FastAPI server
  RESPONSE=$(curl -s -X POST "http://$OLLAMA_SERVER_ADDRESS:$OLLAMA_PORT/query" -H "Content-Type: application/json" -d "{\"question\": \"$QUESTION\"}")

  # Extract the answer from the JSON response using jq
  ANSWER=$(echo "$RESPONSE" | jq -r '.answer')

  # Check if jq failed to parse the answer
  if [ "$ANSWER" == "null" ]; then
    echo "Failed to parse response. Please check if the server is running and the endpoint is correct."
    exit 1
  fi

  # Print the answer in green text
  print_green "$ANSWER"
fi
