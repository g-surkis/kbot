APP=$(shell basename -s .git $(shell git remote get-url origin))
REGISTRY=surkis
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETARCH=$(shell go env GOARCH)
TARGETOS=${shell go env GOOS}

format:
	gofmt -s -w ./

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/g-surkis/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

lint: 
	golint

test: 
	go test -v

clean:
	rm -rf kbot