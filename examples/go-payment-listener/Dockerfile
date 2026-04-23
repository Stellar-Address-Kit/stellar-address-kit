# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copy the entire workspace to handle the local module replace
# In a real production environment, you would use the public module URL
COPY . .

WORKDIR /app/examples/go-payment-listener
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o listener ./cmd/listener

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/
COPY --from=builder /app/examples/go-payment-listener/listener .
COPY --from=builder /app/examples/go-payment-listener/config.example.yaml ./config.yaml

EXPOSE 9090

ENTRYPOINT ["./listener", "--config", "config.yaml"]
