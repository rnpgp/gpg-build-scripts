FROM centos:7

ARG GNUPG_VERSION=latest
ARG CONFIGURE_OPTS="--enable-gpg2-is-gpg"

RUN yum install -y \
      gcc make sudo \
      autoconf automake libtool bison \
      bzip2 gzip bzip2-devel zlib-devel gettext-devel \
      ncurses-devel

RUN rpm --import https://github.com/riboseinc/yum/raw/master/ribose-packages.pub && \
    curl -L https://github.com/riboseinc/yum/raw/master/ribose.repo \
      -o /etc/yum.repos.d/ribose.repo && \
    yum -y install ribose-automake116

WORKDIR /usr/local/src/gpg-build-scripts
COPY . .
RUN ./install_gpg_all.sh --suite-version "${GNUPG_VERSION}" --sudo --configure-opts "${CONFIGURE_OPTS}" --ldconfig

WORKDIR /root
