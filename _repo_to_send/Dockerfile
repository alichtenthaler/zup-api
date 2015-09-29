FROM ntxcode/ruby-base:2.2.1

EXPOSE 80

VOLUME /usr/src/app/log
VOLUME /usr/src/app/public/uploads
VOLUME /usr/src/app/config/permissions
VOLUME /usr/src/app/public/shared_images
VOLUME /usr/src/app/db/shapes

RUN cd /tmp \
    && curl -O http://nginx.org/download/nginx-1.8.0.tar.gz \
    && tar xzf nginx-1.8.0.tar.gz \
    && gem install passenger \
    && passenger-install-nginx-module --auto --nginx-source-dir=/tmp/nginx-1.8.0 --extra-configure-flags=none --languages=ruby

#########################
# Install postgres client
#########################
# Fix those
# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && rm -rf /var/lib/apt/lists/* \
	&& curl -s -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -s -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

RUN curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

ENV PG_MAJOR 9.4
ENV POSTGIS_MAJOR 2.1

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/postgres.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-client-9.4 || true

RUN mkdir -p /usr/src/app/tmp \
	&& mkdir -p /usr/src/app/public/uploads/tmp \
	&& mkdir -p /usr/src/app/log \
	&& chown -R www-data. /usr/src/app

RUN bundle config --global frozen 1 && \
    mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY Gemfile      /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development --deployment -j`getconf _NPROCESSORS_ONLN`

COPY . /usr/src/app

COPY nginx.conf /etc/nginx/nginx.conf

RUN sed -ri "s@PASSENGER_ROOT@`passenger-config --root`@" /etc/nginx/nginx.conf \
    && ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx \
    && mkdir -p /var/log/nginx

COPY boot.sh /boot.sh
RUN chmod +x /boot.sh

WORKDIR /usr/src/app

RUN apt-get purge -y --auto-remove git-core && \
    rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log && \
    cd / && rm -rf /tmp/* || true

CMD ["/boot.sh"]
