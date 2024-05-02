# Start from a base image with Python and required tools
FROM python:3.10

# Install necessary dependencies for whisper.cpp
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    libssl-dev \
    portaudio19-dev \
    ffmpeg \
    && apt-get clean

# Install FastAPI and Uvicorn
RUN pip install fastapi
RUN pip install uvicorn

# Clone whisper.cpp repository
RUN git clone https://github.com/ggerganov/whisper.cpp /usr/local/src/whisper.cpp

# Build whisper.cpp
RUN cd /usr/local/src/whisper.cpp && cmake . && make

# Copy the FastAPI app script into the container
COPY app.py /app/app.py

# Set working directory
WORKDIR /app

# Make the port available to the world outside this container
EXPOSE $PORT

# Run the FastAPI app using Uvicorn
CMD uvicorn server:app --host 0.0.0.0 --port $PORT

