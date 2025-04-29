#!/bin/bash

echo "Starting Chorus Assistant..."
ollama serve &
sleep 15
open-webui serve &

echo "Chorus Assistant started successfully."