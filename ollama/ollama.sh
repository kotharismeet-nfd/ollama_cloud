#!/bin/bash

ollama serve &

until curl -sf http://localhost:11434; do
  echo "Waiting for Ollama server to start..."
  sleep 1
done

ollama pull gemma3:1b

ollama run gemma3:1b

tail -f /dev/null