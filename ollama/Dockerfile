FROM ollama/ollama

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY ollama.sh .

RUN chmod +x ollama.sh

ENTRYPOINT ["bash", "/app/ollama.sh"]