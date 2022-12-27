ARG DEBIAN_RELEASE=bullseye

FROM debian:${DEBIAN_RELEASE}
ARG DEBIAN_RELEASE

# hadolint ignore=DL3008
# echo builder | busybox mkpasswd
# $5$4GhAqthtiejj19Wp$ahxVnqEs6mGYxhHYkwqVpa2wnZaRvC7ZCZIxgNz/GG9
RUN echo "deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE} main" \
    > /etc/apt/sources.list.d/main-src.list \
    && echo "deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free" \
    > /etc/apt/sources.list.d/src.list \
    \
    && apt-get update && apt-get install -qqy --no-install-recommends \
    build-essential dpkg-dev fakeroot devscripts equivs lintian quilt \
    curl vim sudo "bsdtar|libarchive-tools" \
    wget ccache busybox \
    && rm -rf /var/lib/apt/lists/*
RUN \
    && useradd --password $5$4GhAqthtiejj19Wp$ahxVnqEs6mGYxhHYkwqVpa2wnZaRvC7ZCZIxgNz/GG9 -m -s /bin/bash builder \
    && echo 'builder ALL=(ALL) NOPASSWD:/usr/bin/apt-get' >> /etc/sudoers \
    && echo 'PS1="\W> "' >> /home/builder/.bashrc \
    && echo 'PATH="/usr/lib/ccache:$PATH"' >> /home/builder/.bashrc \
    && echo 'CCACHE_DIR="$HOME/.ccache"' >> /home/builder/.bashrc \
    && echo 'CCACHE_REMOTE_STORAGE="file:/workdir/.ccache"' >> /home/builder/.bashrc \
    && echo 'CCACHE_SECONDARY_STORAGE="$CCACHE_REMOTE_STORAGE"' >> /home/builder/.bashrc \
    && echo 'CCACHE_RESHARE="true"' >> /home/builder/.bashrc

COPY entrypoint.sh /
COPY makepkg makerepo updpkgsum /usr/local/bin/
COPY --chown=builder quiltrc /home/builder/.quiltrc

VOLUME [ "/workdir" ]
WORKDIR /workdir

ENTRYPOINT ["/entrypoint.sh"]
