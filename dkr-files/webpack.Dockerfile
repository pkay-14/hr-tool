FROM node:14.16.1-stretch

WORKDIR /myapp

# Git is required for installing node modules from git
RUN apt-get update && apt-get install -qq -y --no-install-recommends git

ADD yarn.lock package.json ./
RUN yarn install
