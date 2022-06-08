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
    bundle install && bundle exec puma -t 2:5 -b tcp://0.0.0.0:8080
else
    bundle exec passenger start --port 9292
fi


