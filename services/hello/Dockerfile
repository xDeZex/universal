FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG TARGETOS TARGETARCH
ARG VERSION=dev
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
  -trimpath \
  -ldflags="-s -w -X main.version=${VERSION}" \
  -o /hello .

FROM scratch
COPY --from=builder /hello /hello
USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/hello"]
