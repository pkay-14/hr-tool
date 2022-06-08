FROM node:14.16.1-stretch as webpack
WORKDIR /myapp
# Git is required for installing node modules from git
RUN apt-get update && apt-get install -qq -y --no-install-recommends git
COPY . .
# Need to be changed via --build-arg
ARG SOURCE_DIRECTORY=dist
ARG PUBLIC_HOST=DOMAIN
RUN yarn install && yarn build-staging

FROM ruby:2.6 as builder

ENV RAILS_ENV production
ENV DEBIAN_FRONTEND noninteractive
ENV BUNDLE_PATH /bundler

WORKDIR /myapp

COPY . .
RUN mkdir -p ./tmp/pids

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential curl wget file
RUN apt-get install -y imagemagick
ARG BUNDLE_LAB__MOCINTRA__COM
RUN bundle config git.allow_insecure true && \
    bundle check || \
    bundle install --jobs 20 --retry 5 --full-index

FROM ruby:2.6-slim

ENV RAILS_ENV production
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /myapp

COPY ./dkr-files/production.startup.sh .

RUN mkdir -p /usr/share/man/man1 && apt-get update && apt-get install -qq -y --no-install-recommends libpq-dev curl wget cron file
RUN apt-get install -y imagemagick
RUN apt-get install -y default-jre
RUN apt-get install -y libreoffice-writer

COPY --from=builder /myapp ./
COPY --from=builder /bundler /usr/local/bundle
COPY --from=webpack /myapp/public/dist ./public/dist

#WORKDIR /myapp
RUN touch /var/log/cron.log

#ADD ./docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf

#RUN cd /myapp && whenever --update-crontab
RUN service cron start

RUN apt-get clean && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod +x production.startup.sh

ENTRYPOINT ["/myapp/production.startup.sh"]

