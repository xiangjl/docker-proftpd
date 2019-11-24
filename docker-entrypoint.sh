#!/bin/bash

if [ -z "$FTP_CREATE_USER" ]; then
	$FTP_CREATE_USER=true
fi

if [ -z "$FTP_USERNAME" ]; then
	$FTP_USERNAME=test
fi

if [ -z "$FTP_PASSWORD" ]; then
	$FTP_PASSWORD=test
fi

if [ -z "$FTP_AUTH_ORDER" ]; then
	$FTP_AUTH_ORDER=pam
fi

if [ -z "$FTP_ENABLE_DYNMASQ" ]; then
	$FTP_ENABLE_DYNMASQ=false
fi

if [ -z "$FTP_CLIENT_GBK" ]; then
        $FTP_CLIENT_GBK=false
fi

if [ ! -f "/usr/local/etc/proftpd.conf" ]; then
	mkdir -p "/usr/local/etc/proftpd.d/"
	cp "/docker/proftpd-include.conf" "/usr/local/etc/proftpd.conf"
	cp "/docker/proftpd-main.conf" "/usr/local/etc/proftpd.d/proftpd.conf"
	cp "/docker/proftpd-vroot.conf" "/usr/local/etc/proftpd.d/mod_vroot.conf"
	cp "/docker/proftpd-delay.conf" "/usr/local/etc/proftpd.d/mod_delay.conf"

	if [ "$FTP_AUTH_ORDER" == "file" ]; then
		cp "/docker/proftpd-auth-file.conf" "/usr/local/etc/proftpd.d/mod_auth.conf"
	fi
	
	if [ "$FTP_CLIENT_GBK" == "true" ]; then
		cp "/docker/proftpd-lang.conf" "/usr/local/etc/proftpd.d/mod_lang.conf"
	fi

	if [ "$FTP_ENABLE_DYNMASQ" == "true" ]; then
		cp "/docker/proftpd-dynmasq.conf" "/usr/local/etc/proftpd.d/mod_dynmasq.conf"
	fi

	if [ "$FTP_CREATE_USER" == "true" ]; then
		if [ -n "$FTP_USERNAME" ]; then
			mkdir -p /data/ftproot/$FTP_USERNAME/
			chown 5000:5000 /data/ftproot/$FTP_USERNAME/
			chmod 775 /data/ftproot/$FTP_USERNAME/

			if [ -n "$FTP_PASSWORD" ]; then
				if [ "$FTP_AUTH_ORDER" == "file" ]; then
                	        	echo $FTP_PASSWORD | ftpasswd --passwd --name test --uid 5000 --gid 5000 --home /data/ftproot/$FTP_USERNAME --shell /sbin/nologin --file /usr/local/etc/proftpd.d/ftpd.passwd --stdin
                        		ftpasswd --group --name $FTP_USERNAME -gid 5000 --file /usr/local/etc/proftpd.d/ftpd.group
                		else
					groupadd -g 5000 $FTP_USERNAME
					useradd -u 5000 -g 5000 -s /sbin/nologin -d  /data/ftproot/$FTP_USERNAME $FTP_USERNAME
					echo $FTP_PASSWORD | passwd --stdin $FTP_USERNAME
				fi
                	fi

		fi
	fi
fi

exec "$@"
