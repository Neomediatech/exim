#!/bin/bash

FQDN_MAIL=${FQDN_MAIL:-noservername.domain.tld}
CERT_DIR="/etc/letsencrypt/live/${FQDN_MAIL}"
LOGDIR="/var/log/exim4"

if [ ! -d "${LOGDIR}" ]; then
    mkdir -p "${LOGDIR}"
    chown Debian-exim:adm "${LOGDIR}"
    chmod 750 "${LOGDIR}"
    chmod g+s "${LOGDIR}"
fi

if [ ! -f "${LOGDIR}/mainlog" ]; then
    touch "${LOGDIR}/mainlog"
    chown Debian-exim:adm "${LOGDIR}/mainlog"
    chmod 640 "${LOGDIR}/mainlog"
fi

[ ! -d ${CERT_DIR} ] && mkdir -p ${CERT_DIR}
[ ! -f ${CERT_DIR}/privkey.pem ] && /gencert.sh 

if [ ! -d /proc/sys/net/ipv6 ]; then 
    grep -q disable_ipv6 /etc/exim4/* -R
    if [ $? -ne 0 ]; then
        echo 'disable_ipv6 = true' > /etc/exim4/conf.d/main/01_custom
    fi
fi

update-exim4.conf

exec tail -f ${LOGDIR}/mainlog &
exec "$@"
