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
EXPOSE 8080
WORKDIR /myapp
ENV DEBIAN_FRONTEND noninteractive
COPY . .
COPY ./dkr-files/staging.startup.sh .
RUN mkdir -p ./tmp/pids
RUN mkdir -p ./sidekiq/letter_opener
RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential curl wget
RUN apt-get install -y imagemagick
RUN gem install bundler && gem install rack
ARG BUNDLE_LAB__MOCINTRA__COM
RUN bundle config git.allow_insecure true
RUN bundle config git.allow_insecure true && \
    bundle check || \
    bundle install --jobs 20 --retry 5 --full-index

FROM ruby:2.6-slim
WORKDIR /myapp
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -qq -y --no-install-recommends libpq-dev curl wget cron file
RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y imagemagick
RUN apt-get install -y default-jre
RUN apt-get install -y libreoffice-writer
COPY --from=builder /myapp ./
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=webpack /myapp/public/dist ./public/dist
RUN touch /var/log/cron.log
#RUN cd /myapp && whenever --update-crontab
