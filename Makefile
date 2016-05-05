LOCAL_NAME=opencv
VERSION=master-cuda7.0-cudnn4


.PHONY: all build test

all: build

build:
	docker build -t $(LOCAL_NAME):$(VERSION) --rm .
