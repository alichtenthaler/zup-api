FROM ntxcode/base-ruby:latest
MAINTAINER Nathan Ribeiro, ntxdev <nathan@ntxdev.com.br>

VOLUME /usr/src/app/log
VOLUME /usr/src/app/public/uploads

RUN apt-get purge -y --auto-remove git-core && \
    rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log

CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile"]