ARG BUILD_FROM

FROM $BUILD_FROM

# Default ENV
ENV \
    LANG="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1 

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Version
ARG \
    BASHIO_VERSION \
    TEMPIO_VERSION \
    S6_OVERLAY_VERSION \
    NODE_VERSION \
    WALLABAG_VERSION

# Base system
WORKDIR /usr/src
ARG BUILD_ARCH

# Setup base
RUN \
    set -x && \
    apt update && apt install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      openssl \
      software-properties-common \
      nginx \
      mariadb-client \
      tzdata \
      locales \
      gettext-base \
    #common debian docker base instructions
    && mkdir -p /usr/share/man/man1 \
    \
    && if [ "${BUILD_ARCH}" = "armv7" ]; then \
            export S6_ARCH="arm"; \
        elif [ "${BUILD_ARCH}" = "i386" ]; then \
            export S6_ARCH="x86"; \
        else \
            export S6_ARCH="${BUILD_ARCH}"; \
        fi \
    \
    && curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" \
        | tar zxvf - -C / \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && curl -L -f -s -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/tempio \
    \
    && mkdir -p /usr/src/bashio \
    && curl -L -f -s "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
        | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /usr/lib/bashio \
    && rm -f /usr/bin/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    # Prepare install of nodeJS
    && curl 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key' | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_${NODE_VERSION}.x $(lsb_release -cs) main" > /etc/apt/sources.list.d/nodesource.list \
    #Install and config PHP 8.0
    && curl -J -L -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list \
    && apt update \
    && apt install  -y --no-install-recommends \
        php8.0-bcmath \
        php8.0-cli \
        php8.0-curl \
        php8.0-fpm \
        php8.0-gd \
        php8.0-intl \
        php8.0-mbstring \
        php8.0-opcache \
        php8.0-gettext \
        php8.0-iconv \
        php8.0-mysql \
        php8.0-sockets \
        php8.0-tidy \
        php8.0-zip \
        php8.0-redis \
        php8.0-imagick \
        php8.0-xdebug \
        php8.0-xml \
        php8.0 \
        imagemagick \
        nodejs \
    # remove unecessary packages
    && apt purge -y --auto-remove \
        software-properties-common \
    && apt clean
# Copy Wallabag sources
WORKDIR /var/www
RUN curl -L -o wb_latest.tgz https://static.wallabag.org/releases/wallabag-release-${WALLABAG_VERSION}.tar.gz && tar xvf wb_latest.tgz \
    && rm -f wb_latest.tgz && mv wallabag-${WALLABAG_VERSION} wallabag

# S6-Overlay
WORKDIR /

# Copy root filesystem
COPY rootfs /

ENTRYPOINT ["/init"]