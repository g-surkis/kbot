APP=$(shell basename -s .git $(shell git remote get-url origin))
REGISTRY=surkis
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETARCH=$(shell go env GOARCH)
TARGETOS=${shell go env GOOS}

ARCH=$(lastword $(subst /, ,${PLATFORMS}))

format:
	gofmt -s -w ./

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/g-surkis/kbot/cmd.appVersion=${VERSION}

# image:
# 	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

image:
	docker buildx build --platform ${PLATFORMS} \
		-t ${REGISTRY}/${APP}:${VERSION}-${ARCH} --push .

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

lint: 
	golint

test: 
	go test -v

clean:
	rm -rf kbot