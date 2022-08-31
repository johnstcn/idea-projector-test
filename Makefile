IMAGE_NAME:="ghcr.io/johnstcn/idea-projector-test:latest"

all: build push

.PHONY: build
build:
  @docker build . -t $(IMAGE_NAME)

.PHONY: push
push:
  @docker push $(IMAGE_NAME)

.PHONY: clean
clean:
  @docker rmi -f $(IMAGE_NAME)