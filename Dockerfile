FROM golang:1.24.1 AS builder

WORKDIR /go/src/app

COPY . .
# RUN export LLMROUTER_API_KEY=${LLMROUTER_API_KEY}

RUN GOOS=linux GOARCH=arm64 go build -o build/llm-router /go/src/app/cmd
FROM golang:1.24.1

WORKDIR /go/src/app

COPY --from=builder /go/src/app/build/llm-router /usr/local/bin/llm-router

RUN chmod +x /usr/local/bin/llm-router

CMD ["/usr/local/bin/llm-router"]