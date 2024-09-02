
## README

### Overview

This repository contains a set of scripts and a FastAPI server to interact with a Retrieval-Augmented Generation (RAG) model running inside a Docker container. The scripts facilitate the management of documents, querying the RAG model, and unloading data from the model. Below is a description of each file and its usage.

### Contents

- **addDoc.sh**: A Bash script to load a text file into the RAG model running on a FastAPI server.
- **OllamaServer.py**: A FastAPI server script that manages document loading, querying, and unloading for the RAG model.
- **qa.sh**: A Bash script to query the RAG model via the FastAPI server, with an optional interactive mode.
- **startDocker.sh**: A Bash script to set up and start the Docker container with the necessary environment for running the RAG model.
- **stopDocker.sh**: A Bash script to stop and remove the Docker container.
- **unload.sh**: A Bash script to unload all documents from the RAG model, clearing its state.

### Usage

#### 1. Setting Up the Docker Environment

Before using any other scripts, you need to set up the Docker environment:

```bash
./startDocker.sh
```

This script will:
- Check for the `~/knowledge` directory and create it if it doesn’t exist.
- Pull the Ollama Docker image and run the Docker container with GPU support.
- Install necessary Python libraries inside the Docker container.
- Start the FastAPI server (`OllamaServer.py`) inside the Docker container.

#### 2. Loading a Document into the RAG Model

To load a document into the RAG model:

```bash
./addDoc.sh <filename>
```

Replace `<filename>` with the path to your text file. This script reads the file content and sends it to the FastAPI server’s `/load` endpoint.

#### 3. Querying the RAG Model

To query the RAG model, you have two options:

- **Non-Interactive Mode**:

  ```bash
  ./qa.sh "What is the main idea of the document?"
  ```

  Replace the quoted text with your question.

- **Interactive Mode**:

  ```bash
  ./qa.sh -interactive
  ```

  In this mode, you can continuously ask questions until you type `exit`.

#### 4. Unloading Documents from the RAG Model

To clear all documents from the RAG model:

```bash
./unload.sh
```

This script sends a request to the FastAPI server’s `/unload` endpoint to clear all loaded documents.

#### 5. Stopping the Docker Environment

To stop and remove the Docker container:

```bash
./stopDocker.sh
```

This script stops the Docker container running the FastAPI server and removes it to clean up the environment.

### Prerequisites

- **Docker**: Ensure Docker is installed and running on your system.
- **jq**: Install `jq` for parsing JSON responses in the scripts:
  - For Ubuntu/Debian: `sudo apt-get install jq`
  - For macOS: `brew install jq`
