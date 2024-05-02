from fastapi import FastAPI, File, UploadFile
import subprocess, os

app = FastAPI()

@app.post("/transcribe/")
async def transcribe(file: UploadFile = File(...)):
    # Save the uploaded file temporarily
    file_path = f"/tmp/{file.filename}"
    with open(file_path, "wb") as f:
        f.write(await file.read())
    
    # Construct command to transcribe the file using whisper.cpp
    cmd = [
        "/usr/local/src/whisper.cpp/main",
        "transcribe", file_path
    ]
    
    # Run the transcription command and capture output
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    # Remove the temporary file
    os.remove(file_path)

    # Return the transcription output
    return {"transcription": result.stdout}
