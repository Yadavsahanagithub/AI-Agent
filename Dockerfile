FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose ports for services
EXPOSE 8000 8001 8002 8003 8004 8005 8006

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Create a script to start all services
RUN echo '#!/bin/bash\n\
uvicorn backend.orchestrator:app --host 0.0.0.0 --port 8000 & \
uvicorn backend.agents.api_agent:app --host 0.0.0.0 --port 8001 & \
uvicorn backend.agents.language_agent:app --host 0.0.0.0 --port 8005 & \
uvicorn backend.agents.voice_agent:app --host 0.0.0.0 --port 8006 & \
wait\n' > /app/start.sh && chmod +x /app/start.sh

# Command to run when container starts
CMD ["/app/start.sh"]
