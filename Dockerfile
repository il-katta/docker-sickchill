FROM lsiobase/python:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SICKCHILL_COMMIT
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="homerr"

# set python to use utf-8 rather than ascii
ENV PYTHONIOENCODING="UTF-8"
ENV GLIBC_VERSION 2.29-r0
RUN \
echo "**** install packages ****" && \
 apk add --no-cache --upgrade && \
 apk add --no-cache \
	nodejs && \
 curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
 curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
 curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
 apk add glibc-bin.apk glibc.apk && \
 /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
 echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
 rm -rf glibc.apk glibc-bin.apk /var/cache/apk/* && \
echo "**** fetch sickchill ****" && \
mkdir -p \
	/app/sickchill && \
if [ -z ${SICKCHILL_COMMIT+x} ]; then \
	SICKCHILL_COMMIT=$(curl -sX GET https://api.github.com/repos/sickchill/sickchill/commits/master \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
fi && \
echo "found ${SICKCHILL_COMMIT}" && \
curl -o \
/tmp/sickchill.tar.gz -L \
	"https://github.com/sickchill/sickchill/archive/${SICKCHILL_COMMIT}.tar.gz" && \
tar xf \
	/tmp/sickchill.tar.gz -C \
	/app/sickchill/ --strip-components=1

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8081
VOLUME /config /downloads /tv
