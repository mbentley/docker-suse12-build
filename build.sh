#!/bin/bash

set -e

DOCKER_VERSION=${DOCKER_VERSION:-1.9.1-cs3}
ENGINE_TYPE=${ENGINE_TYPE:-cs}
TEMP_DIR=${TEMP_DIR:-/data}

### check to see if TEMP_DIR exists
if [ ! -d ${TEMP_DIR} ]
then
  echo "Creating ${TEMP_DIR}"
  mkdir ${TEMP_DIR}
fi

# set engine type based on env var
case $ENGINE_TYPE in
  cs)
    GIT_REPO="cs-docker"
    ;;
  oss)
    GIT_REPO="docker"
    ;;
  *)
    echo "Invalid ENGINE_TYPE (cs|oss)"
    exit 1
    ;;
esac

### clone and checkout docker repository
git clone https://github.com/docker/${GIT_REPO}.git
cd ${GIT_REPO}
git checkout tags/v${DOCKER_VERSION}
AUTO_GOPATH=1 DOCKER_BUILDTAGS="selinux" hack/make.sh dynbinary

### create directory
mkdir ${TEMP_DIR}/suse12_docker-engine-${DOCKER_VERSION}

### copy necessary files over
cp --parents bundles/${DOCKER_VERSION}/dynbinary/docker-${DOCKER_VERSION} bundles/${DOCKER_VERSION}/dynbinary/dockerinit-${DOCKER_VERSION} contrib/udev/80-docker.rules contrib/init/systemd/docker.service contrib/init/systemd/docker.socket contrib/completion/bash/docker contrib/completion/zsh/_docker contrib/completion/fish/docker.fish contrib/syntax/vim/doc/dockerfile.txt contrib/syntax/vim/ftdetect/dockerfile.vim contrib/syntax/vim/syntax/dockerfile.vim contrib/syntax/nano/Dockerfile.nanorc ${TEMP_DIR}/suse12_docker-engine-${DOCKER_VERSION}

### create install script
cat <<EOF > ${TEMP_DIR}/suse12_docker-engine-${DOCKER_VERSION}/install.sh
#!/bin/bash

set -e

DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"
cd \$DIR

### install docker
# docker binaries
echo "installing docker binaries"
install -d /usr/lib/docker
install -p -m 755 bundles/${DOCKER_VERSION}/dynbinary/docker-${DOCKER_VERSION} /usr/bin/docker
install -p -m 755 bundles/${DOCKER_VERSION}/dynbinary/dockerinit-${DOCKER_VERSION} /usr/lib/docker/dockerinit

# udev rules
echo "installing udev rules"
install -p -m 755 contrib/udev/80-docker.rules /usr/lib/udev/rules.d/80-docker.rules

# systemd
echo "installing systemd files"
install -d /usr/lib/systemd/system/
install -p -m 644 contrib/init/systemd/docker.service /usr/lib/systemd/system/docker.service
install -p -m 644 contrib/init/systemd/docker.socket /usr/lib/systemd/system/docker.socket

# completions
echo "installing completions"
install -d /usr/share/bash-completion/completions
install -d /usr/share/zsh/vendor-completions
install -d /usr/share/fish/completions
install -p -m 644 contrib/completion/bash/docker /usr/share/bash-completion/completions/docker
install -p -m 644 contrib/completion/zsh/_docker /usr/share/zsh/vendor-completions/_docker
install -p -m 644 contrib/completion/fish/docker.fish /usr/share/fish/completions/docker.fish

# add vimfiles
echo "installing vimfiles"
install -d /usr/share/vim/vimfiles/doc
install -d /usr/share/vim/vimfiles/ftdetect
install -d /usr/share/vim/vimfiles/syntax
install -p -m 644 contrib/syntax/vim/doc/dockerfile.txt /usr/share/vim/vimfiles/doc/dockerfile.txt
install -p -m 644 contrib/syntax/vim/ftdetect/dockerfile.vim /usr/share/vim/vimfiles/ftdetect/dockerfile.vim
install -p -m 644 contrib/syntax/vim/syntax/dockerfile.vim /usr/share/vim/vimfiles/syntax/dockerfile.vim

# add nano
echo "installing nanofiles"
install -d /usr/share/nano
install -p -m 644 contrib/syntax/nano/Dockerfile.nanorc /usr/share/nano/Dockerfile.nanorc

# reload systemd configuration
systemctl daemon-reload

# installation complete
echo "installation complete."
echo "make sure to enable and start the docker daemon when ready:"
echo "systemctl enable docker"
echo "systemctl start docker"

echo "done."
EOF

### set permissions on install script
chmod u+x ${TEMP_DIR}/suse12_docker-engine-${DOCKER_VERSION}/install.sh

### create tar.gz
cd ${TEMP_DIR}
tar czvf suse12_docker-engine-${DOCKER_VERSION}.tar.gz suse12_docker-engine-${DOCKER_VERSION}

### cleanup build directory
rm -rf ${TEMP_DIR}/suse12_docker-engine-${DOCKER_VERSION}

### build complete
echo -e "\nsuse12_docker-engine-${DOCKER_VERSION} build complete!"
ls -l ${TEMP_DIR}/suse12_docker-engine-${DOCKER_VERSION}.tar.gz
