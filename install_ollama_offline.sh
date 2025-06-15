#!/bin/bash

# === CONFIGURATION ===
ARCHIVE="ollama-linux-amd64.tgz"
MODEL_NAME="coder"

# === CHECK FILES ===
if [ ! -f "$ARCHIVE" ]; then
    echo "OLLAMA archive '$ARCHIVE' not found."
    exit 1
fi

if [ ! -f "Modelfile" ]; then
    echo "Modelfile missing."
    exit 1
fi

# === CHECK IF RUNNING AS ROOT ===
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# === INSTALL OLLAMA ===
echo "Installing OLLAMA from $ARCHIVE..."
sudo tar -C /usr -xzf "$ARCHIVE" || {
    echo "Failed to extract OLLAMA archive."
    exit 1
}

# === START OLLAMA SERVER ===
echo "Starting OLLAMA server in background..."
nohup ollama serve > ollama.log 2>&1 &
# Wait for OLLAMA to start
echo "Waiting for OLLAMA server to start..."
for i in {1..10}; do
    if pgrep -x "ollama" > /dev/null; then
        echo "OLLAMA server started."
        break
    fi
    echo "Attempting to start OLLAMA server... ($i)"
    sleep 2
done

# Check if OLLAMA server started
if ! pgrep -x "ollama" > /dev/null; then
    echo "Failed to start OLLAMA server."
    exit 1
fi

# === CHECK INSTALLATION ===
echo "Checking OLLAMA version..."
ollama -v || {
    echo "OLLAMA not installed correctly."
    exit 1
}

# === CREATE MODEL ===
echo "Creating model '$MODEL_NAME'..."
ollama create "$MODEL_NAME" || {
    echo "Failed to create model from Modelfile."
    exit 1
}

# === VERIFY MODEL ===
echo "Verifying model registration..."
if ! ollama list | grep -q "$MODEL_NAME"; then
    echo "Model '$MODEL_NAME' creation failed."
    exit 1
fi

# === CHECK FOR ERRORS IN LOG FILE ===
if grep -q "ERROR" ollama.log; then
    echo "Error found in ollama.log during startup."
    cat ollama.log
    exit 1
fi

# Success message
echo "Model '$MODEL_NAME' created and OLLAMA is running successfully."
