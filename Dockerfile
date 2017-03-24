FROM alpine:3.5

MAINTAINER 04n0 <http://github.com/04n0>

ENV OC_VERSION=7.08

RUN buildDeps="curl file g++ gnutls-dev gpgme gzip libev-dev \
              libnl3-dev libseccomp-dev libxml2-dev linux-headers \
              linux-pam-dev lz4-dev make readline-dev tar " && \
    imagePkgs="gnutls gnutls-utils iptables libev libintl procps\
              libnl3 libseccomp linux-pam lz4 openssl readline sed \
              libxml2 nmap-ncat socat openssh-client" && \
    set -x && \
    apk add --update $imagePkgs && \
    apk add $buildDeps && \
    curl -SL "ftp://ftp.infradead.org/pub/openconnect/openconnect-$OC_VERSION.tar.gz" -o openconnect.tar.gz && \
    curl -SL "ftp://ftp.infradead.org/pub/openconnect/openconnect-$OC_VERSION.tar.gz.asc" -o openconnect.tar.gz.asc && \
    gpg --keyserver pgp.mit.edu --recv-key 0x63762cda67e2f359 && \
    gpg --verify openconnect.tar.gz.asc && \
    mkdir -p /etc/vpnc && \
    curl http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/HEAD:/vpnc-script -o /etc/vpnc/vpnc-script && \
    chmod 750 /etc/vpnc/vpnc-script && \
    mkdir -p /usr/src/openconnect && \
    tar -xf openconnect.tar.gz -C /usr/src/openconnect --strip-components=1 && \
    rm openconnect.tar.gz* && \
    cd /usr/src/openconnect && \
    ./configure && \
    make && \
    make install && \
    mkdir -p /etc/openconnect && \
    cd / && \
    mkdir -p /openconnect/ && \
    addgroup -S openconnect && \
    rm -fr /usr/src/openconnect && \
    apk del $buildDeps && \
    rm -rf /var/cache/apk/*

ADD openconnect.sh /usr/bin

WORKDIR /etc/openconnect

ENTRYPOINT ["nohup", "/entrypoint.sh"]

EXPOSE 40022
