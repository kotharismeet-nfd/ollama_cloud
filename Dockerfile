FROM golang:1.24.1 AS builder

WORKDIR /go/src/app

COPY . .

RUN make build
RUN ls -l /go/src/app/build

FROM golang:1.24.1

WORKDIR /go/src/app

COPY --from=builder /go/src/app/build /go/src/app/build

RUN chmod +x /go/src/app/build/llm-router-local  
# Ensure the binary is executable

CMD ["/bin/bash", "-c", "/go/src/app/build/llm-router-local"]