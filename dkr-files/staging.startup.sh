#!/bin/bash

echo "Environment: $SERVER_ROLE"

if [ "$SERVER_ROLE" == "web" ]
then
    bundle exec puma -t 2:5 -b tcp://0.0.0.0:8080
else
    bundle exec passenger start --port 9292
fi

bundle exec rake db:migrate
