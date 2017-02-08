FROM php:7.0-fpm

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        git-core \
        imagemagick \
        libicu-dev \
        libmcrypt-dev \
        libghc-postgresql-libpq-dev \
        imagemagick
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# APCU
RUN pecl install apcu-5.1.8 \
    && docker-php-ext-enable apcu

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/include/postgresql/

RUN docker-php-ext-install \
    bcmath \
    intl \
    mbstring \
    mcrypt \
    pcntl \
    pdo_pgsql \
    pgsql \
    shmop \
    zip

# Dredd
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get -qq update && apt-get install -y nodejs

RUN npm install -g dredd

# Imagick
RUN runtimeRequirements="libmagickwand-6.q16-dev --no-install-recommends" \
    && apt-get update \
    && apt-get install -y ${runtimeRequirements} \
    && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin/ \
    && pecl install imagick \ # && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install channel://pecl.php.net/redis-3.0.0 && docker-php-ext-enable redis

# Install composer
RUN curl -k -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN export VERSION=`php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${VERSION} \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so `php -r "echo ini_get('extension_dir');"`/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=\${BLACKFIRE_PORT}" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/*

# Workaround for write permission on write to MacOS X volumes
# See https://github.com/boot2docker/boot2docker/pull/534
RUN usermod -u 1000 www-data

ADD config/cli/php.ini /usr/local/etc/php/php.ini
ADD config/conf.d/global.ini /usr/local/etc/php/conf.d/global.ini
ADD config/conf.d/intl.ini /usr/local/etc/php/conf.d/intl.ini
ADD config/conf.d/modules.ini /usr/local/etc/php/conf.d/modules.ini
ADD config/conf.d/redis.ini /usr/local/etc/php/conf.d/redis.ini

WORKDIR /srv/api

ENV GIT_DIR=/srv/api
ENV COMPOSER_GITHUB_OAUTH_TOKEN=0905db4776fcda6d9b5e535dec21dd592f381aca

ADD ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm", "-F"]
