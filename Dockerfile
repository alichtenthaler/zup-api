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

RUN mkdir -p /usr/src/app/tmp \
	&& mkdir -p /usr/src/app/public/uploads/tmp \
	&& mkdir -p /usr/src/app/log \
	&& chown -R www-data. /usr/src/app

RUN bundle config --global frozen 1 && \
    mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY Gemfile      /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development:test --deployment

COPY . /usr/src/app

RUN apt-get purge -y --auto-remove git-core && \
    rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log && \
    cd / && rm -rf /tmp/*

COPY nginx.conf /etc/nginx/nginx.conf

RUN sed -ri "s@PASSENGER_ROOT@`passenger-config --root`@" /etc/nginx/nginx.conf \
    && ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx \
    && mkdir -p /var/log/nginx

CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile"]
