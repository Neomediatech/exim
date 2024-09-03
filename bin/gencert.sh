#!/bin/bash -e

source /data/certs/live/cert.conf

#MAILSERVER_CERT=${MAILSERVER_CERT:-noservername.domain.tld}

countryName="NN"
stateOrProvinceName="NoWhere"
localityName="IvryUr"
organizationName="MyCorp"
organizationalUnitName="MyOU"

# build random data (if 'diceware' is installed)
which diceware 1>/dev/null
if [ $? -eq 0 ]; then
    RANDOMAIN="$(diceware --no-caps -n 2).$(diceware --no-caps -n 2|cut -b -3)"

    [ "$MAILSERVER_CERT" = "noservername.domain.tld" ] && MAILSERVER_CERT=${RANDOMAIN}

    countryName="$(diceware -n 2|tr -d [:lower:])"
    stateOrProvinceName="$(diceware -n 2)"
    localityName="$(diceware -n 2)"
    organizationName="$(diceware -n 1) Corp"
    organizationalUnitName="$(diceware -n 1) OU"
    emailAddress="$(diceware --no-caps -n 1)@${MAILSERVER_CERT}"
fi

# valid for three years
DAYS=1095

CERT_DIR="${CERT_DIR:-${BASE_CERT_DIR}/${MAILSERVER_CERT}}"

CERT=${CERT_DIR}/fullchain.pem
KEY=${CERT_DIR}/privkey.pem

[ ! -d ${CERT_DIR} ] && mkdir -p ${CERT_DIR}
SSLEAY="$(mktemp /tmp/exiXXXXXXX)"

cat > $SSLEAY <<EOM
[ req ]
default_bits = 2048
default_keyfile = exim.key
distinguished_name = req_distinguished_name
prompt = no
[ req_distinguished_name ]
countryName = $countryName
stateOrProvinceName = $stateOrProvinceName
localityName = $localityName
organizationName = $organizationName
organizationalUnitName = $organizationalUnitName
commonName = ${MAILSERVER_CERT}
emailAddress = $emailAddress
EOM

echo "[*] Creating a self signed SSL certificate for Exim!"
echo "    This may be sufficient to establish encrypted connections but for"
echo "    secure identification you need to buy a real certificate!"
echo "    "
echo "    Please enter the hostname of your MTA at the Common Name (CN) prompt!"
echo "    "

openssl req -config $SSLEAY -x509 -newkey rsa:2048 -keyout $KEY -out $CERT -days $DAYS -nodes
#see README.Debian.gz*# openssl dhparam -check -text -5 512 -out $DH
rm -f $SSLEAY

chown root:Debian-exim $KEY $CERT $DH
chmod 640 $KEY $CERT $DH

echo "MAIN_TLS_CERTIFICATE = $BASE_CERT_DIR/$MAILSERVER_CERT/fullchain.pem" > /etc/exim4/conf.d/main/00_exim4-config_listmacrosdefs-custom
echo "MAIN_TLS_PRIVATEKEY = $BASE_CERT_DIR/$MAILSERVER_CERT/privkey.pem" >> /etc/exim4/conf.d/main/00_exim4-config_listmacrosdefs-custom
echo "MAIN_TLS_ENABLE = yes" >> /etc/exim4/conf.d/main/00_exim4-config_listmacrosdefs-custom
echo "tls_on_connect_ports = 25 : 465 : 587" >> /etc/exim4/conf.d/main/00_exim4-config_listmacrosdefs-custom

echo "[*] Done generating self signed certificates for exim!"
echo "    Refer to the documentation and example configuration files"
echo "    over at /usr/share/doc/exim4-base/ for an idea on how to enable TLS"
echo "    support in your mail transfer agent."
