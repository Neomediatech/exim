# Dockerized Exim on Ubuntu

This image ~~is~~ will be heavily dependent on a complex docker stack, including (but not still done):
* clamav (with zip unzip rar unrar unace bzip2 gzip)
* mariadb 
* rspamd
* razor
* pyzor
* redis
* dcc
* certbot (for smtp sessions and webmail (maybe with traefik?))

Because of very customized and critical settings, all Exim config files are bind mounted on host in /etc/exim4/. May be we'll publish them in future, but for now they remains hidden.  

(test) docker run --rm -it -v /host-exim-conf/:/etc/exim4/ --name exim-local exim-local


# WARNING
Nothing is workink here, for now.

Bad things can happens. YHBW
