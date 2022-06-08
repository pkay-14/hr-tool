#!/bin/bash

export APP_USER="hrmodule"
#export BUNDLE_GEMFILE="/home/$APP_USER/Gemfile"
export BUNDLE_JOBS=2
export BUNDLE_PATH="/home/$APP_USER/bundle"
export RACK_ENV="development"

echo "Environment: $SERVER_ROLE"

if [ "$SERVER_ROLE" == "web" ]
then
    rsync -avzu $BUNDLE_PATH/gems /home/hrmodule/src/vendor/gems
    export $(cat .env | xargs)
    bundle install && bundle exec passenger start --port 8080 --log-file log/hrdev_web.log
else
    bundle exec passenger start --port 9292
fi


