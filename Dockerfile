FROM flavio/opensuse-12-3:latest
MAINTAINER Matt Bentley <mbentley@mbentley.net>

# install dependencies
RUN zypper -n in ca-certificates* curl git gzip rpm-build &&\
  zypper -n in libbtrfs-devel device-mapper-devel glibc-static libselinux-devel selinux-policy selinux-policy-devel sqlite-devel tar

# install go
RUN curl -fSL "https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz" | tar xzC /usr/local
ENV PATH $PATH:/usr/local/go/bin

COPY build.sh /build.sh

CMD ["/build.sh"]
