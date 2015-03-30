FROM ntxcode/ruby-base:2.2.1-onbuild
MAINTAINER Nathan Ribeiro, ntxdev <nathan@ntxdev.com.br>

VOLUME /usr/src/app/log
VOLUME /usr/src/app/public/uploads
VOLUME /usr/src/app/tmp
VOLUME /usr/src/app/config/permissions

RUN apt-get purge -y --auto-remove git-core && \
    rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log

EXPOSE 80

CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile"]
