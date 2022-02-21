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
* fail2ban
* dnsbl-ipset.sh
* cron

Because of very customized and critical settings, all Exim config files are bind mounted on host in /etc/exim4/. May be we'll publish them in future, but for now they remains hidden.  

If you bind-mount your config files on /data/exim4/conf container they will be used.  
The tree of the config files must be the same as they are on /etc/exim4  

(test) docker run --rm -it -v /host-exim-conf/:/etc/exim4/ --name exim-local exim-local

# WARNING
Maybe something is not working, use this image with caution, bad things can happens. YHBW  

## Environment Variables
| Name                | Description                                                     | Default         |
| ------------------- | --------------------------------------------------------------- | --------------- |
| EXIM_LOGDIR         | Path for Exim logfiles                                          | /var/log/exim4/ |
| EXIM_OPTIONS        | Additional (but optional) command line options for Exim startup |                 |
| QUEUE_CYCLE         | time interval for the queue runner                              | 1m (one minute) |

## From source version
There's also an image version compiled from Exim (Debian/Ubuntu) sources.  
This because we need DMARC and SPF support, not included in default exim4-daemon-heavy Ubuntu package.

