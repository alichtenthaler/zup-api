FROM phusion/passenger-customizable:0.9.14

# Setup
RUN /build/ruby2.0.sh
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
ADD ./docker/nginx.conf /etc/nginx/sites-enabled/zup-api.conf
RUN echo "gem: --no-ri --no-rdoc" > /etc/gemrc
RUN ruby-switch --set ruby2.0
RUN gem install bundler

WORKDIR /tmp
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
RUN bundle install

# Application deployment
RUN mkdir /home/app/zup-api
WORKDIR /home/app/zup-api
ADD . /home/app/zup-api
RUN chown -R app:app /home/app
ADD ./docker/app-env.conf /etc/nginx/main.d/
ADD ./docker/passenger.conf /etc/nginx/conf.d/
RUN touch /home/app/zup-api/config/database.yml

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9595
CMD ["/sbin/my_init"]
