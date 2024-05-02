from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
import httpx

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

@app.api_route("/{path_name:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def forward_request(request: Request, path_name: str):
    # Forward the request to the whisper.cpp server
    async with httpx.AsyncClient() as client:
        url = f"{WHISPER_SERVER_URL}/{path_name}"
        method = request.method
        headers = request.headers
        data = await request.body()

        response = await client.request(method, url, headers=headers, data=data)

    return Response(content=response.content, status_code=response.status_code, headers=dict(response.headers))