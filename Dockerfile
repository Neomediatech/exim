FROM neomediatech/ubuntu-base:20.04

ENV VERSION=4.93-13ubuntu1.1 \
    SERVICE=exim

LABEL maintainer="docker-dario@neomediatech.it" \ 
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/${SERVICE} \
      org.label-schema.maintainer=Neomediatech

RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends mariadb-client exim4-daemon-heavy libswitch-perl redis-tools openssl && \
    rm -rf /var/lib/apt/lists* && \
    useradd -u 5000 -U -s /bin/false -m -d /var/spool/virtual vmail 

COPY bin/* /
RUN chmod +x /entrypoint.sh /gencert.sh /init.sh
RUN /init.sh

EXPOSE 25 465 587

# ToDO: more useful check, like a whole transaction
# HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=20 CMD nc -w 7 -zv 0.0.0.0 25
      
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/tini","--","/usr/sbin/exim4","-bd","-q1m"]
