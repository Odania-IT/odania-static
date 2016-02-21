FROM odaniait/docker-base:latest
MAINTAINER Mike Petersen <mike@odania-it.de>

# Setup nginx
RUN rm /etc/nginx/sites-enabled/default
COPY templates/vhost.conf /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/service/static
COPY docker/runit_static.sh /etc/service/static/run

COPY . /srv/odania

WORKDIR /srv/odania
RUN bundle install

VOLUME ["/srv/static"]

EXPOSE 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
