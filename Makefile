LOCAL_NAME=opencv
VERSION=`git rev-parse --abbrev-ref HEAD`
PUBLIC_NAME=docker-opencv
REPOSITORY=bfolkens
DOCKER=docker


.PHONY: all build tag release

all: build

build:
	$(DOCKER) build -t $(LOCAL_NAME):$(VERSION) --rm .

tag:
	$(DOCKER) tag $(LOCAL_NAME):$(VERSION) $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

release: tag
	$(DOCKER) push $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

