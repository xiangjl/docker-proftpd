FROM centos:7
MAINTAINER XiangJL <xjl-tommy@qq.com>

# install software
RUN yum update -y && \
    yum install -y git gcc make gettext file pam-devel mysql-devel && \
    yum clean all && \
    mkdir {/docker,/data}

COPY proftpd-1.3.6b.tar.gz /usr/local/src/proftpd-1.3.6b.tar.gz
COPY proftpd-mod_vroot-0.9.5.tar.gz /usr/local/src/mod_vroot-0.9.5.tar.gz
COPY docker-entrypoint.sh /docker/entrypoint.sh
COPY proftpd-include.conf /docker/proftpd-include.conf
COPY proftpd-main.conf /docker/proftpd-main.conf
COPY proftpd-vroot.conf /docker/proftpd-vroot.conf
COPY proftpd-lang.conf /docker/proftpd-lang.conf
COPY proftpd-delay.conf /docker/proftpd-delay.conf 
COPY proftpd-dynmasq.conf /docker/proftpd-dynmasq.conf 
COPY proftpd-auth-file.conf /docker/proftpd-auth-file.conf 

RUN cd /usr/local/src/ && \
#    curl ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.6b.tar.gz > proftpd-1.3.6b.tar.gz && \
#    curl https://github.com/Castaglia/proftpd-mod_vroot/archive/v0.9.5.tar.gz > mod_vroot-0.9.5.tar.gz && \
    tar zxvf proftpd-1.3.6b.tar.gz && \ 
    tar zxvf mod_vroot-0.9.5.tar.gz && \
    mv proftpd-mod_vroot-0.9.5/ proftpd-1.3.6b/contrib/mod_vroot && \
    cd /usr/local/src/proftpd-1.3.6b && \
    ./configure --enable-dso --enable-nls --enable-shadow --with-libraries="/usr/lib/mysql" --with-includes="/usr/include/mysql" --with-modules=mod_readme:mod_auth_pam --with-shared=mod_sql:mod_sql_passwd:mod_sql_mysql:mod_ifsession:mod_snmp:mod_vroot:mod_dynmasq && \
    make && \
    make install && \
    mv /usr/local/etc/proftpd.conf /usr/local/etc/proftpd.conf.bak && \
    yum remove -y git gcc make && \
    yum clean all && \
    rm -rf /usr/local/src/*

EXPOSE 21/tcp 50001-50030/tcp

ENTRYPOINT ["/docker/entrypoint.sh"]

CMD ["proftpd", "--nodaemon"]
