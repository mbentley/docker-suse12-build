all: image run

DOCKER_VERSION ?= 1.9.1
GIT_REPO ?= docker/docker

image:
	@docker build -t mbentley/suse12-build:latest .

build:
	@docker run -it --rm -v /data/suse12-build:/data -e DOCKER_VERSION=$(DOCKER_VERSION) -e GIT_REPO=$(GIT_REPO) -e TEMP_DIR=/data mbentley/suse12-build:latest

.PHONY: all image build
