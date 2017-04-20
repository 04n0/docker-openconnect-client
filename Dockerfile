FROM library/alpine:3.5

MAINTAINER 04n0 <http://github.com/04n0>

ENV OC_VERSION=7.08

ARG PACKAGES_BUILD="curl file g++ gnutls-dev gpgme gzip libev-dev \
                    libnl3-dev libseccomp-dev libxml2-dev linux-headers \
                    linux-pam-dev lz4-dev make readline-dev tar"
ARG PACKAGES_IMAGE="gnutls gnutls-utils iptables libev libintl procps \
                    libnl3 libseccomp linux-pam lz4 openssl readline sed \
                    libxml2 nmap-ncat socat openssh-client"
ARG BUILD_DIR=/build

RUN \
# add alpine packages
    apk add --no-cache --update ${PACKAGES_IMAGE} && \
    apk add --no-cache ${PACKAGES_BUILD} && \
# create build dir, download, verify and decompress OC package to build dir
    mkdir -p ${BUILD_DIR}/openconnect && \
    cd ${BUILD_DIR} && \
    curl -SL "ftp://ftp.infradead.org/pub/openconnect/openconnect-$OC_VERSION.tar.gz" -o ${BUILD_DIR}/openconnect.tar.gz && \
    curl -SL "ftp://ftp.infradead.org/pub/openconnect/openconnect-$OC_VERSION.tar.gz.asc" -o ${BUILD_DIR}/openconnect.tar.gz.asc && \
    gpg --keyserver pgp.mit.edu --recv-key 0x63762cda67e2f359 && \
    gpg --verify ${BUILD_DIR}/openconnect.tar.gz.asc && \
    tar -xf /build/openconnect.tar.gz -C ${BUILD_DIR}/openconnect --strip-components=1 && \
    rm ${BUILD_DIR}/openconnect.tar.gz* && \
# download vpnc-script
    mkdir -p /etc/vpnc && \
    curl http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/HEAD:/vpnc-script -o /etc/vpnc/vpnc-script && \
    chmod 750 /etc/vpnc/vpnc-script && \
# autoconf + make + make install
    cd ${BUILD_DIR}/openconnect && \
    ./configure && \
    make && \
    make install && \
    cd ${BUILD_DIR} && \
# environment preps
    mkdir -p /etc/openconnect && \
    mkdir -p /openconnect/ && \
    addgroup -S openconnect && \
# cleanup
    apk del ${PACKAGES_BUILD} && \
    rm -rf /var/cache/apk/* && \
    rm -rf ${BUILD_DIR}/openconnect

COPY openconnect.sh /usr/bin

WORKDIR /etc/openconnect

ENTRYPOINT ["nohup", "/entrypoint.sh"]

EXPOSE 40022
