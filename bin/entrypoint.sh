#!/bin/bash

mkdir -p /var/log/exim4/ /etc/letsencrypt/live/noservername.domain.tld/

update-exim4.conf

exec tail -F /var/log/exim4/mainlog &
exec "$@"
