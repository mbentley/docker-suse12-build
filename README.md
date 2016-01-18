mbentley/suse12-build
=====================

docker image for building docker engine (suse 12)
based off of flavio/opensuse-12-3:latest

To pull this image:
`docker pull mbentley/suse12-build`

Example usage:

```
docker run -it --rm \
  -v /data/suse12-build:/data \
  -e DOCKER_VERSION=1.9.1 \
  -e GIT_REPO=docker/docker \
  -e TEMP_DIR=/data \
  mbentley/suse12-build:latest
```
