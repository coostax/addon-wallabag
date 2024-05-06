ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:5.3.1
# hadolint ignore=DL3006
FROM $BUILD_FROM

# Set versions in ENV
ENV NODE_VERSION=18
ENV WALLABAG_VERSION=2.6.9

# Setup base
# hadolint ignore=DL3008,DL4006
RUN \
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
      gnupg \
      lsb-release \
      openssl \
      software-properties-common \
      nginx \
      mariadb-client \
      locales \
      gettext-base \
    # Prepare install of nodeJS
    && curl 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key' | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_${NODE_VERSION}.x $(lsb_release -cs) main" > /etc/apt/sources.list.d/nodesource.list \
    #Install and config PHP 8.2
    && curl -J -L -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install  -y --no-install-recommends \
        php8.2-bcmath \
        php8.2-cli \
        php8.2-curl \
        php8.2-fpm \
        php8.2-gd \
        php8.2-intl \
        php8.2-mbstring \
        php8.2-opcache \
        php8.2-gettext \
        php8.2-iconv \
        php8.2-mysql \
        php8.2-sockets \
        php8.2-tidy \
        php8.2-zip \
        php8.2-redis \
        php8.2-imagick \
        php8.2-xdebug \
        php8.2-xml \
        php8.2 \
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
RUN curl -L -o wb_latest.tgz https://github.com/wallabag/wallabag/releases/download/${WALLABAG_VERSION}/wallabag-${WALLABAG_VERSION}.tar.gz \
    && tar xvf wb_latest.tgz \
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
