FROM centos:7

ARG GNUPG_VERSION=latest
ARG CONFIGURE_OPTS="--enable-gpg2-is-gpg"

RUN yum install -y bzip2 gcc make sudo ncurses-devel

WORKDIR /usr/local/src/gpg-build-scripts
COPY . .
RUN ./install_gpg_all.sh --suite-version "${GNUPG_VERSION}" --sudo --configure-opts "${CONFIGURE_OPTS}"

WORKDIR /root
