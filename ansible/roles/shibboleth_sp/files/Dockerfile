FROM ubuntu:focal

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get -y install apache2 libapache2-mod-shib2 supervisor && \
    a2enmod ssl rewrite proxy_http headers && \
    a2dissite 000-default.conf && \
    apt-get -y clean

COPY ./supervisor/*.conf /etc/supervisor/conf.d/
COPY ./docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 443 80

CMD ["supervisord", "-n"]
