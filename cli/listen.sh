#!/bin/zsh

# Try connecting to whisper endpoint
if ! curl -s "http://localhost:9000/asr" &> /dev/null; then
  echo "Whisper endpoint not detected, starting container..."

  # # Check if image exists
  # if ! docker images | grep -q "onerahmet/openai-whisper-asr-webservice"; then
  #   echo "Pulling whisper image..."
  #   docker pull onerahmet/openai-whisper-asr-webservice:latest
  # fi

  # # Run container
  # docker run -d \
  #   -p 9000:9000 \
  #   --name whisper \
  #   onerahmet/openai-whisper-asr-webservice:latest

  # echo "Whisper container started"
else
  echo "Whisper endpoint already running"
fi
