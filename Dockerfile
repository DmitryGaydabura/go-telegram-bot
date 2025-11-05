# syntax=docker/dockerfile:1.6

# Base build image (alternative registry, not Docker Hub)
FROM quay.io/projectquay/golang:1.22 AS base
WORKDIR /src
ENV CGO_ENABLED=0

# Build-time args set by Makefile (must match host platform/arch when not using buildx)
ARG TARGETOS
ARG TARGETARCH

# Copy go module files first for better caching
COPY go.mod go.sum* ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

# Copy the rest of the source
COPY . .

# Compile a static binary for the requested GOOS/GOARCH (host-only with standard docker build)
RUN --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -o /out/app ./

# A tester stage which will run `go test` at container runtime (across all packages)
FROM base AS tester
CMD ["go", "test", "./..."]

# Runtime stage (keep golang base as requested). Contains only the built binary.
FROM quay.io/projectquay/golang:1.22 AS runtime
WORKDIR /app
COPY --from=base /out/app /app/app
ENTRYPOINT ["/app/app"]
