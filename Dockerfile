#ARG DEBIAN_RELEASE=bullseye
ARG DEBIAN_RELEASE=bookworm

FROM debian:${DEBIAN_RELEASE}
ARG DEBIAN_RELEASE

# use it with
# docker run -ti --rm -v $(pwd):/workdir     -e "DEBEMAIL=$(git config --get user.email)"     ghcr.io/berlin4apk/debian-pkgdevel:bookworm
# docker run -ti --rm -v $(pwd):/workdir     -e "DEBEMAIL=$(git config --get user.email)"     ghcr.io/berlin4apk/debian-pkgdevel-test:bookworm
# ccache -sv
# dget --build http://deb.debian.org/debian/pool/main/h/hello/hello_2.10-2.dsc
# ccache -sv



# hadolint ignore=DL3008
# busybox mkpasswd -m sha-512 "builder" | sed 's/\$/\\$/g'
# 
#RUN echo "deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE} main" \
#    > /etc/apt/sources.list.d/main-src.list \
#    && echo "deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free" \
#    > /etc/apt/sources.list.d/src.list \

RUN echo "build /etc/apt/sources.list.d/deb-src.list, and apt-get install" \
    && cp -p /etc/apt/sources.list /etc/apt/sources.list.bak && sed -i 's/main$/main contrib non-free/' /etc/apt/sources.list \
    && grep '^deb ' /etc/apt/sources.list | sed 's/^deb /deb-src /g' | tee /etc/apt/sources.list.d/deb-src.list \
    && apt-get update && apt-get install -qqy --no-install-recommends \
           build-essential dpkg-dev fakeroot devscripts equivs lintian quilt \
           curl vim sudo "bsdtar|libarchive-tools" \
           wget ccache distcc busybox apt-file debian-keyring \
    && rm -rf /var/lib/apt/lists/*

#RUN cat > /usr/local/etc/ccache.conf << __EOF__
#RUN cat >> /etc/ccache.conf << __EOF__
#ccache_dir = $HOME/.ccache
#remote_storage = file:/workdir/.ccache 
#secondary_storage = file:/workdir/.ccache 
#reshare = true
#__EOF__

### RUN echo "build /etc/ccache.conf" \
    ### && echo "ccache_dir = $HOME/.ccache" >> /etc/ccache.conf \
    ### && echo "remote_storage = file:/workdir/.ccache" >> /etc/ccache.conf \
    ### && echo "secondary_storage = file:/workdir/.ccache" >> /etc/ccache.conf \
    ### && echo "reshare = true" >> /etc/ccache.conf
    # && echo 'PATH="/usr/lib/ccache:$PATH"' > /etc/profile.d/ccache.sh && echo 'export PATH' >> /etc/profile.d/ccache.sh

# https://www.netfort.gr.jp/~dancer/diary/daily/2008-Aug-30.html.en
# DEBUILD_SET_ENVVAR_CCACHE_PREFIX="distcc"
# DEBUILD_SET_ENVVAR_DISTCC_HOSTS="coreduo.local akkeee.local" # names of machines to use in the build.
# DEBUILD_PREPEND_PATH=/usr/lib/ccache
# 

# https://www.hiroom2.com/2017/11/20/ubuntu-1710-deb-src-en/
RUN echo "useradd builder" \
    && useradd --password \$5\$RPPeiX3VnSDJgNII\$R7p2yDAGs7BS.3b.Tz1D8ciQ/NHrXTlnHTsrRNeMHX7 -m -s /bin/bash builder \
    && echo 'Defaults timestamp_timeout=0' > /etc/sudoers.d/builder \
    && echo 'builder ALL=(ALL) ALL' >> /etc/sudoers.d/builder \
    && echo 'builder ALL=(ALL) NOPASSWD:/usr/bin/apt-get' >> /etc/sudoers.d/builder \
    && echo 'PS1="\W> "' >> /home/builder/.bashrc \
    && echo 'export PATH="/usr/lib/ccache:$PATH"' >> /home/builder/.bashrc
###    && echo 'export PATH="/usr/lib/ccache:$PATH"' > /etc/profile.d/ccache.sh # && echo 'export PATH' >> /etc/profile.d/ccache.sh

    # && echo 'builder ALL=(ALL) NOPASSWD:/usr/bin/apt-get' >> /etc/sudoers \
    # && echo 'builder ALL=(ALL) ALL' >> /etc/sudoers \
    # && echo 'CCACHE_DIR="$HOME/.ccache"' >> /home/builder/.bashrc \
    # && echo 'CCACHE_REMOTE_STORAGE="file:/workdir/.ccache"' >> /home/builder/.bashrc \
    # && echo 'CCACHE_SECONDARY_STORAGE="file:/workdir/.ccache"' >> /home/builder/.bashrc \
    # && echo 'CCACHE_RESHARE="true"' >> /home/builder/.bashrc

RUN  echo 'export CCACHE_DIR="$HOME/.ccache"' >> /home/builder/.bashrc \
     && echo 'export CCACHE_REMOTE_STORAGE="file:/workdir/.ccache"' >> /home/builder/.bashrc \
     && echo 'export CCACHE_SECONDARY_STORAGE="file:/workdir/.ccache"' >> /home/builder/.bashrc \
     && echo 'export CCACHE_RESHARE="true"' >> /home/builder/.bashrc \
     && echo 'DEBUILD_PREPEND_PATH="/usr/lib/ccache"' | tee -a /home/builder/.devscripts \
     && echo 'DEBUILD_PRESERVE_ENVVARS="CCACHE_DIR,CCACHE_RESHARE,CCACHE_SECONDARY_STORAGE,CCACHE_REMOTE_STORAGE"' | tee -a /home/builder/.devscripts


COPY entrypoint.sh /
COPY makepkg makerepo updpkgsum /usr/local/bin/
COPY --chown=builder quiltrc /home/builder/.quiltrc

VOLUME [ "/workdir" ]
WORKDIR /workdir

ENTRYPOINT ["/entrypoint.sh"]
