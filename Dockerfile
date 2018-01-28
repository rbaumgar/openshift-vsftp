FROM registry.access.redhat.com/rhel7
# FROM docker.io/centos:centos7

MAINTAINER Robert Baumgartner <rbaumgar@redhat.com>

LABEL Description="RHEL 7 based vsftpd server. Supports passive mode and virtual users."

# RUN yum -y install \
RUN yum -y install --disablerepo "*" --enablerepo rhel-7-server-rpms \
           vsftpd db4-utils db4 && \
    yum clean all

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
    chown -R ftp:ftp /home/vsftpd/ && \
    chmod +r /usr/sbin/run-vsftpd.sh && \
    chown ftp:ftp /etc/vsftpd/vsftpd.conf

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 2020 2021

#USER ftp
USER 14 

CMD ["/usr/sbin/run-vsftpd.sh"]
