#!/bin/bash

FQDN_MAIL=${FQDN_MAIL:-noservername.domain.tld}
CERT_DIR="/etc/letsencrypt/live/${FQDN_MAIL}"
LOGDIR=${LOGDIR:-/var/log/exim4}
HONEYPOT=${HONEYPOT:-false}

if [ "$HONEYPOT" == "false" ]; then
  if [ "$LOGDIR" == "stdout" ]; then
    mkdir -p /var/log/exim4
    rm -f /var/log/exim4/{mainlog,rejectlog,paniclog}
    ln -s /dev/stdout /var/log/exim4/mainlog
    ln -s /dev/stdout /var/log/exim4/rejectlog
    ln -s /dev/stdout /var/log/exim4/paniclog
  else
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
  fi
fi

# Check custom configuration files
SRC_DIR="/data"
DST_DIR="/etc/exim4"
if [ -d "${SRC_DIR}" ]; then
  cd "${SRC_DIR}"
  for FILE in $(find . -type f|cut -b 3-); do
    DIR_FILE="$(dirname "$FILE")"
    if [ ! -d "$DST_DIR/$DIR_FILE" ]; then
      mkdir -p "$DST_DIR/$DIR_FILE"
    fi
    if [ -f "$DST_DIR/$FILE}" ]; then
      echo "  WARNING: $DST_DIR/$FILE already exists and will be overriden"
      rm -f "$DST_DIR/$FILE"
    fi
    echo "  Add custom config file $DST_DIR/$FILE ..."
    ln -sf "$SRC_DIR/$FILE" "$DST_DIR/$FILE"
  done
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

if [ "$LOGDIR" != "stdout" ]; then
  exec tail -F ${LOGDIR}/mainlog &
fi
exec "$@"
