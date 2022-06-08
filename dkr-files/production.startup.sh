#!/bin/bash
bundle exec puma -t 2:5 -b tcp://0.0.0.0:3000
