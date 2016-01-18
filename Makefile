all: build run

build:
	@docker build -t mbentley/suse12-build:latest .

run:
	@docker run -it --rm -v /data/suse12-build:/data -e DOCKER_VERSION=1.9.1 -e GIT_REPO=docker/docker -e TEMP_DIR=/data mbentley/suse12-build:latest

.PHONY: all build run
