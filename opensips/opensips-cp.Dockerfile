FROM mich43l/debian:bookworm

ARG OPENSIPS_CP_VER=9.3.4

ENV APACHE_LOG_DIR=/var/log/apache2 \
  APACHE_RUN_DIR=/var/run/apache2 \
  APACHE_PID_FILE=/var/run/apache2/apache2.pid \
  APACHE_RUN_USER=www-data \
  APACHE_RUN_GROUP=www-data

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  python3-pip \
  libpq-dev \
  sudo \
  pkg-config \
  file \
  build-essential \
  libbcg729-0 \
  libsndfile1 \
  libsystemd-dev \
  postgresql-client \
  apache2 \
  libapache2-mod-php \
  php-curl \
  php \
  php-mysql \
  php-gd \
  php-pear \
  php-cli \
  php-apcu \
  php-pgsql \
  && rm -rf /var/lib/apt/lists

RUN git clone --branch=$OPENSIPS_CP_VER https://github.com/OpenSIPS/opensips-cp.git /var/www/html/opensips-cp
RUN chown -R www-data:www-data /var/www/html/opensips-cp/

COPY units/etc/apache2/apache2.conf /etc/apache2
COPY units/etc/apache2/sites-available /etc/apache2/sites-available

RUN rm -rf /etc/apache2/sites-available/default-ssl.conf

RUN a2dissite 000-default.conf
RUN a2ensite opensips-cp.conf
RUN a2dismod ssl

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

VOLUME ["/etc/opensips"]
VOLUME ["/etc/apache2/"]
VOLUME ["/var/www/html/opensips-cp"]

EXPOSE 80/tcp

ADD units/etc/service/apache2 /etc/service/apache2
RUN chmod +x /etc/service/apache2/run