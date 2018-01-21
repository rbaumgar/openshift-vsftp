FROM registry.access.redhat.com/rhel7
MAINTAINER Robert Baumgartner <rbaumgar@redhat.com>
LABEL Description="RHEL 7 based vsftpd server. Supports passive mode and virtual users."

#RUN yum -y update && \
#    yum clean all && \
#    yum -y install httpd && \
RUN yum-config-manager --disable rhel-7-server-htb-rpms,rhel-7-rc-rpms,rhel-7-server-aus-rpms,rhel-7-server-htb-rpms,\
              rhel-7-server-nfv-rpms,rhel-7-server-rpms,rhel-7-server-rt-beta-rpms,rhel-7-server-rt-rpms,\
              rhel-7-server-tus-rpms && \
    yum install -y  vsftpd db4-utils db4

ENV FTP_USER **String** \
    FTP_PASS **Random** \
    PASV_ADDRESS **IPv4** \
    PASV_MIN_PORT 21100 \
    PASV_MAX_PORT 21110 \
    LOG_STDOUT **Boolean**

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh && \
    mkdir -p /home/vsftpd/ && \
    chown -R ftp:ftp /home/vsftpd/

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21

CMD ["/usr/sbin/run-vsftpd.sh"]
