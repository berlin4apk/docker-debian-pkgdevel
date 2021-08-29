ARG DEBIAN_RELEASE=bullseye

FROM debian:${DEBIAN_RELEASE}
ARG DEBIAN_RELEASE

RUN echo "deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE} main" \
    > /etc/apt/sources.list.d/main-src.list \
    \
    && apt-get update && apt-get install -qqy --no-install-recommends \
    build-essential dpkg-dev dpatch fakeroot devscripts equivs lintian \
    quilt curl vim sudo \
    && rm -rf /var/lib/apt/lists/* \
    \
    && useradd -m -s /bin/bash builder \
    && echo 'builder ALL=(ALL) NOPASSWD:/usr/bin/apt-get' >> /etc/sudoers


COPY entrypoint.sh /
COPY --chown=builder quiltrc /home/builder/.quiltrc

VOLUME [ "/workdir" ]
WORKDIR /workdir

ENTRYPOINT ["/entrypoint.sh"]
