# Makefile for building binaries and Docker images across platforms/architectures
# Requirements: Go toolchain, Docker (standard docker build; no buildx).

APP_NAME ?= product
VERSION  ?= 0.1.0

# Alternative registry to avoid Docker Hub limits.
REGISTRY  ?= ghcr.io
NAMESPACE ?= $(shell whoami)
IMAGE_TAG ?= $(REGISTRY)/$(NAMESPACE)/$(APP_NAME):$(VERSION)

HOST_OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
HOST_ARCH_RAW := $(shell uname -m)

# Normalize arch names
ifeq ($(HOST_ARCH_RAW),x86_64)
  HOST_ARCH := amd64
else ifeq ($(HOST_ARCH_RAW),aarch64)
  HOST_ARCH := arm64
else ifeq ($(HOST_ARCH_RAW),arm64)
  HOST_ARCH := arm64
else
  HOST_ARCH := $(HOST_ARCH_RAW)
endif

.PHONY: all build linux darwin windows arm64 amd64 image test clean print-host

print-host:
	@echo "HOST_OS=$(HOST_OS) HOST_ARCH=$(HOST_ARCH)"

all: build

# Build a binary for the host platform/arch (single main package at ./)
build:
	@mkdir -p bin
	GOOS=$(HOST_OS) GOARCH=$(HOST_ARCH) CGO_ENABLED=0 \
	  go build -o bin/$(APP_NAME)-$(HOST_OS)-$(HOST_ARCH) ./

# OS-specific binaries (arch = current host arch)
linux:
	@mkdir -p bin
	GOOS=linux GOARCH=$(HOST_ARCH) CGO_ENABLED=0 \
	  go build -o bin/$(APP_NAME)-linux-$(HOST_ARCH) ./

darwin:
	@mkdir -p bin
	GOOS=darwin GOARCH=$(HOST_ARCH) CGO_ENABLED=0 \
	  go build -o bin/$(APP_NAME)-darwin-$(HOST_ARCH) ./

windows:
	@mkdir -p bin
	GOOS=windows GOARCH=$(HOST_ARCH) CGO_ENABLED=0 \
	  go build -o bin/$(APP_NAME)-windows-$(HOST_ARCH).exe ./

# Arch-specific binaries (OS = current host OS)
arm64:
	@mkdir -p bin
	GOOS=$(HOST_OS) GOARCH=arm64 CGO_ENABLED=0 \
	  go build -o bin/$(APP_NAME)-$(HOST_OS)-arm64 ./

amd64:
	@mkdir -p bin
	GOOS=$(HOST_OS) GOARCH=amd64 CGO_ENABLED=0 \
	  go build -o bin/$(APP_NAME)-$(HOST_OS)-amd64 ./

# Build a Linux container image targeting the host platform/arch ONLY (no buildx/QEMU)
image:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg TARGETOS=$(HOST_OS) \
	  --build-arg TARGETARCH=$(HOST_ARCH) \
	  -t $(IMAGE_TAG) .

# Build a test-runner image (same host platform/arch) that executes `go test ./...` when run
test:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg TARGETOS=$(HOST_OS) \
	  --build-arg TARGETARCH=$(HOST_ARCH) \
	  --target tester \
	  -t $(IMAGE_TAG)-tests .

# Clean artifacts and remove created images
clean:
	rm -rf bin
	- docker rmi $(IMAGE_TAG) || true
	- docker rmi $(IMAGE_TAG)-tests || true
