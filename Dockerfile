FROM ubuntu:18.04

ENV VERSION=4.90.1-1ubuntu1.4 \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Rome \
    SERVICE=exim-ubuntu

LABEL maintainer="docker-dario@neomediatech.it" \ 
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/${SERVICE} \
      org.label-schema.maintainer=Neomediatech

COPY bin/* /

RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y mariadb-client exim4-daemon-heavy libswitch-perl redis-tools && \
    rm -rf /var/lib/apt/lists* && \
    useradd -u 5000 -U -s /bin/false -m -d /var/spool/virtual vmail && \
    chmod +x /entrypoint.sh /tini-static-amd64 && \
    ln -s /tini-static-amd64 /tini

EXPOSE 25 465 587

# ToDO: more useful check, like a whole transaction
# HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=20 CMD nc -w 7 -zv 0.0.0.0 25
      
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/tini","--","/usr/sbin/exim4","-bd","-q1m"]

# volumes:
# /etc/timezone:/etc/timezone:ro
# /etc/localtime:/etc/localtime:ro
# /etc/locale.gen:/etc/locale.gen:ro


# container clamav con i pacchetti zip unzip rar unrar unace bzip2 gzip
# container con db mysql
# container rspamd
# container razor
# container pyzor
# container redis
# container dcc
# container certbot per certificato ssl per sessioni smtp (container traefik?)
#
# fail2ban, dnsbl-ipset.sh, cron
