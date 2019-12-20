#!/bin/bash

mkdir -p /var/log/exim4/

update-exim4.conf

exec tail -F /var/log/exim4/mainlog &
exec "$@"
