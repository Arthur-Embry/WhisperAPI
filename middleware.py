from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import httpx
import os

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define the URL of the internal whisper.cpp server
WHISPER_SERVER_URL = "http://localhost:8000"

# Serve demo.html at the root
@app.get("/")
async def serve_html():
    try:
        # Open and read the HTML file
        with open("demo.html", "r") as file:
            content = file.read()
        return Response(content=content, media_type="text/html")
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="demo.html not found")

# Define a generic route to forward requests to whisper.cpp server
@app.api_route("/{path_name:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def forward_request(request: Request, path_name: str):
    async with httpx.AsyncClient() as client:
        url = f"{WHISPER_SERVER_URL}/{path_name}"
        method = request.method
        headers = request.headers
        data = await request.body()

        response = await client.request(method, url, headers=headers, data=data)

    return Response(content=response.content, status_code=response.status_code, headers=dict(response.headers))
