LOCAL_NAME=opencv
VERSION=master-cuda7.0-cudnn4
PUBLIC_NAME=docker-opencv
REPOSITORY=bfolkens


.PHONY: all build tag release

all: build tag release

build:
	docker build -t $(LOCAL_NAME):$(VERSION) --rm .

tag: build
	docker tag -f $(LOCAL_NAME):$(VERSION) $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

release: tag
	docker push $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

