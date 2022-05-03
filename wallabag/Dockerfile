ARG BUILD_FROM
# hadolint ignore=DL3006
FROM $BUILD_FROM

# Default ENV
ENV \
    LANG="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    BASHIO_VERSION=0.14.3 \
    TEMPIO_VERSION=2021.09.0 \
    S6_OVERLAY_VERSION=2.1.0.2 \
    NODE_VERSION=16 \
    WALLABAG_VERSION=2.4.3

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Base system
WORKDIR /usr/src
ARG BUILD_ARCH

# Setup base
# hadolint ignore=DL3008
RUN \
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
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
    && curl -L -f -s "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /usr/lib/bashio \
    && rm -f /usr/bin/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    # Prepare install of nodeJS
    && curl 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key' | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_${NODE_VERSION}.x $(lsb_release -cs) main" > /etc/apt/sources.list.d/nodesource.list \
    #Install and config PHP 8.0
    && curl -J -L -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install  -y --no-install-recommends \
        php8.1-bcmath \
        php8.1-cli \
        php8.1-curl \
        php8.1-fpm \
        php8.1-gd \
        php8.1-intl \
        php8.1-mbstring \
        php8.1-opcache \
        php8.1-gettext \
        php8.1-iconv \
        php8.1-mysql \
        php8.1-sockets \
        php8.1-tidy \
        php8.1-zip \
        php8.1-redis \
        php8.1-imagick \
        php8.1-xdebug \
        php8.1-xml \
        php8.1 \
        imagemagick \
        nodejs \
    # remove unecessary packages
    && apt-get purge -y --auto-remove \
        software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Copy Wallabag sources
WORKDIR /var/www
# hadolint ignore=SC2086
RUN curl -L -o wb_latest.tgz https://static.wallabag.org/releases/wallabag-release-${WALLABAG_VERSION}.tar.gz && tar xvf wb_latest.tgz \
    && rm -f wb_latest.tgz && mv wallabag-${WALLABAG_VERSION} wallabag

# S6-Overlay
WORKDIR /

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG \
    BUILD_ARCH \
    BUILD_DATE \
    BUILD_DESCRIPTION \
    BUILD_NAME \
    BUILD_REF \
    BUILD_REPOSITORY \
    BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Paulo Costa <coostax@duck.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.authors="Paulo Costa <coostax@duck.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/init"]