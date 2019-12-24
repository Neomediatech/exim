#!/bin/bash

FQDN_MAIL=${FQDN_MAIL:-noservername.domain.tld}
CERT_DIR="/etc/letsencrypt/live/${FQDN_MAIL}"
LOGDIR="/var/log/exim4"
CERTDIR=

[ ! -d ${LOGDIR} ] && mkdir -p ${LOGDIR}
[ ! -d ${CERT_DIR} ] && mkdir -p ${CERT_DIR}
[ ! -f ${CERT_DIR}/privkey.pem ] && /gencert.sh "${CERT_DIR}"

update-exim4.conf

exec tail -F ${LOGDIR}/mainlog &
exec "$@"
