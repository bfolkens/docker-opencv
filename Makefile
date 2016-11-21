LOCAL_NAME=opencv
VERSION=`git rev-parse --abbrev-ref HEAD`
PUBLIC_NAME=docker-opencv
REPOSITORY=bfolkens


.PHONY: all build tag release

all: build tag release

build:
	docker build -t $(LOCAL_NAME):$(VERSION) --rm .

tag: build
	docker tag $(LOCAL_NAME):$(VERSION) $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

release: tag
	docker push $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

