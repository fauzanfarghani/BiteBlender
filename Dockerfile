# syntax=docker/dockerfile:1
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama (via curl)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

# Expose ports
EXPOSE 11434
EXPOSE 8501

# Start Ollama + pull model + run app
CMD ["/bin/bash", "-c", "\
    ollama serve & \
    sleep 5 && \
    ollama pull llama3.2:3b && \
    python ingest_csv_to_chroma.py && \
    streamlit run app.py --server.port=8501 --server.address=0.0.0.0 \
"]