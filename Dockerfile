FROM centos:7
MAINTAINER XiangJL <xjl-tommy@qq.com>

ENV PROFTPD_VERSION=1.3.7c
ENV VROOT_VERSION=0.9.9
ENV CLAMAV_VERSION=0.13

# install software
RUN yum update -y && \
    yum install -y git gcc make gettext file pam-devel mysql-devel && \
    yum clean all && \
    mkdir {/docker,/data}

#COPY proftpd-$PROFTPD_VERSION.tar.gz /usr/local/src/proftpd-$PROFTPD_VERSION.tar.gz
#COPY proftpd-mod_vroot-$VROOT_VERSION.tar.gz /usr/local/src/mod_vroot-$VROOT_VERSION.tar.gz

COPY docker-entrypoint.sh /docker/entrypoint.sh
COPY proftpd-include.conf /docker/proftpd-include.conf
COPY proftpd-main.conf /docker/proftpd-main.conf
COPY proftpd-vroot.conf /docker/proftpd-vroot.conf
COPY proftpd-lang.conf /docker/proftpd-lang.conf
COPY proftpd-delay.conf /docker/proftpd-delay.conf 
COPY proftpd-dynmasq.conf /docker/proftpd-dynmasq.conf 
COPY proftpd-auth-file.conf /docker/proftpd-auth-file.conf 
COPY proftpd-clamav.conf /docker/proftpd-clamav.conf 

RUN cd /usr/local/src/ && \
    curl -SL ftp://ftp.proftpd.org/distrib/source/proftpd-$PROFTPD_VERSION.tar.gz > proftpd-$PROFTPD_VERSION.tar.gz && \
    curl -SL https://github.com/Castaglia/proftpd-mod_vroot/archive/v$VROOT_VERSION.tar.gz > mod_vroot-$VROOT_VERSION.tar.gz && \
    curl -SL https://github.com/jbenden/mod_clamav/archive/refs/tags/v$CLAMAV_VERSION.tar.gz > mod_clamav-$CLAMAV_VERSION.tar.gz && \
    tar zxvf proftpd-$PROFTPD_VERSION.tar.gz && \ 
    tar zxvf mod_vroot-$VROOT_VERSION.tar.gz && \
    tar zxvf mod_clamav-$CLAMAV_VERSION.tar.gz && \
    mv proftpd-mod_vroot-$VROOT_VERSION/ proftpd-$PROFTPD_VERSION/contrib/mod_vroot && \
    mv mod_clamav-$CLAMAV_VERSION/mod_clamav.[ch] proftpd-$PROFTPD_VERSION/contrib/ && \
    cd /usr/local/src/proftpd-$PROFTPD_VERSION && \
    ./configure --enable-dso --enable-nls --enable-shadow --with-libraries="/usr/lib/mysql" --with-includes="/usr/include/mysql" --with-modules=mod_readme:mod_auth_pam --with-shared=mod_sql:mod_sql_passwd:mod_sql_mysql:mod_ifsession:mod_snmp:mod_vroot:mod_dynmasq:mod_clamav && \
    make && \
    make install && \
    mv /usr/local/etc/proftpd.conf /usr/local/etc/proftpd.conf.bak && \
    mv /docker/proftpd-include.conf /usr/local/etc/proftpd.conf && \
    yum remove -y git gcc make && \
    yum clean all && \
    rm -rf /usr/local/src/*

EXPOSE 21/tcp 50001-50030/tcp

ENTRYPOINT ["/docker/entrypoint.sh"]

CMD ["proftpd", "--nodaemon"]
