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

# Expose the port
EXPOSE $PORT

# Start the server
CMD /app/whisper.cpp/build/bin/server -m /app/whisper.cpp/models/ggml-base.en.bin -t 8 -p $PORT