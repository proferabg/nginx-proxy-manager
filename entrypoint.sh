#!/bin/bash

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Switch to the container's working directory
cd /home/container/app || exit 1

echo "Starting supervisord"
supervisord -c /supervisor/supervisord.conf

node --abort_on_uncaught_exception --max_old_space_size=250 index.js
