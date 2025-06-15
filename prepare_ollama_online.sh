#!/bin/bash

# === CONFIGURATION ===
OLLAMA_URL="https://ollama.com/download/ollama-linux-amd64.tgz"
MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-Coder-0.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-0.5b-instruct-q8_0.gguf"
MODEL_FILE_NAME="qwen2-0.5b.Q4_K_M.gguf"
MODEL_NAME="coder"

# === CHECK FOR DEPENDENCIES ===
if ! command -v curl &>/dev/null; then
  echo "curl is not installed. Please install curl and try again."
  exit 1
fi

# === CHECK IF URLs ARE ACCESSIBLE ===
curl --head --silent "$OLLAMA_URL" | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null || { echo "OLLAMA URL is not reachable"; exit 1; }
curl --head --silent "$MODEL_URL" | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null || { echo "Model URL is not reachable"; exit 1; }

# === CHECK FOR WRITE PERMISSIONS ===
if [ ! -w . ]; then
  echo "No write permissions in the current directory."
  exit 1
fi

# === DOWNLOAD OLLAMA INSTALLER ===
if [ -f "ollama-linux-amd64.tgz" ]; then
  echo "OLLAMA installer already exists, skipping download."
else
  echo "Downloading OLLAMA installer..."
  curl -L -o ollama-linux-amd64.tgz "$OLLAMA_URL" || { echo "Failed to download OLLAMA installer."; exit 1; }
fi

# === DOWNLOAD GGUF MODEL ===
if [ -f "$MODEL_FILE_NAME" ]; then
  echo "Model file already exists, skipping download."
else
  echo "Downloading model from HuggingFace..."
  curl -L -o "$MODEL_FILE_NAME" "$MODEL_URL" || { echo "Failed to download model."; exit 1; }
fi

# === CREATE Modelfile ===
if [ -f "Modelfile" ]; then
  echo "Modelfile already exists, skipping creation."
else
  echo "Creating Modelfile..."
  cat <<EOF > Modelfile
FROM ./$MODEL_FILE_NAME
EOF
fi

# === FINISHED ===
echo "All files downloaded and prepared."
echo "Copy the downloaded files to your offline machine using USB or external storage."
