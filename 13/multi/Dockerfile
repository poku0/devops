FROM golang:1.20-alpine AS builder

WORKDIR /src

# Copy the source code to the container
COPY . .


ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -ldflags='-s -w' -o /app/main main.go


FROM scratch
COPY --from=builder /app/main /main

ENTRYPOINT ["/sh"]