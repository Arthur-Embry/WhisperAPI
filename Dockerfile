# Use the official lightweight Python image.
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        curl \
        ffmpeg \
        git \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone whisper.cpp repo
RUN git clone https://github.com/ggerganov/whisper.cpp.git /app/whisper.cpp

# Build whisper.cpp
RUN cd /app/whisper.cpp && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)

# Download the base model
RUN cd /app/whisper.cpp && \
    bash ./models/download-ggml-model.sh base.en

# Start the server
RUN /app/whisper.cpp/build/bin/server -m /app/whisper.cpp/models/ggml-base.en.bin -t 8 -p 8000 &

# Install middleware dependencies
RUN pip install --no-cache-dir fastapi uvicorn httpx

# Copy the middleware code to the container
COPY middleware.py .

# Copy the demo code to the container
COPY demo.html .

#Copy the hello world wav for test transcription
COPY hello.wav .

# Expose the port
EXPOSE $PORT

# Run the middleware.py file using uvicorn
CMD uvicorn middleware:app --host 0.0.0.0 --port $PORT