#!/bin/bash

if [ ! -f "/usr/local/etc/proftpd.conf" ]; then
	mkdir -p "/usr/local/etc/proftpd.d/"
	cp "/docker/proftpd-include.conf" "/usr/local/etc/proftpd.conf"
	cp "/docker/proftpd-main.conf" "/usr/local/etc/proftpd.d/proftpd.conf"
	cp "/docker/proftpd-vroot.conf" "/usr/local/etc/proftpd.d/mod_vroot.conf"
	cp "/docker/proftpd-lang.conf" "/usr/local/etc/proftpd.d/mod_lang.conf"
	cp "/docker/proftpd-delay.conf" "/usr/local/etc/proftpd.d/mod_delay.conf"
	cp "/docker/proftpd-dynmasq.conf" "/usr/local/etc/proftpd.d/mod_dynmasq.conf"
	cp "/docker/proftpd-auth.conf" "/usr/local/etc/proftpd.d/mod_auth.conf"

	echo test | ftpasswd --passwd --name test --uid 5000 --gid 5000 --home /data/ftproot/test --shell /sbin/nologin --file /usr/local/etc/proftpd.d/ftpd.passwd --stdin
	ftpasswd --group --name test -gid 5000 --file /usr/local/etc/proftpd.d/ftpd.group
	mkdir -p /data/ftproot/test/
	chown 5000:5000 /data/ftproot/test/
	chmod 775 /data/ftproot/test/
fi

exec "$@"
