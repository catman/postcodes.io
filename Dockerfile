# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>
#
# part 1 copied from The CentOS Project <cloud-ops@centos.org>
# Dockerfile for Centos7 system with postgres >= 9.6 GPS -> postcode library on https://github.com/catman/postcodes.io

# ======
# part 1
# ======
FROM centos:centos7
MAINTAINER catman @ rabbich.com

RUN yum -y update; yum clean all
RUN yum -y install sudo epel-release; yum clean all

WORKDIR /root
RUN rpm -ivh https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
RUN sudo yum list | grep pgdg96

RUN yum -y install postgresql96 postgresql96-server postgresql96-libs postgresql96-contrib postgresql96-devel; yum clean all
RUN yum -y install supervisor pwgen; yum clean all

ADD ./postgresql-setup /usr/bin/postgresql-setup
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start_postgres.sh /start_postgres.sh

#Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers
RUN chmod +x /usr/bin/postgresql-setup
RUN chmod +x /start_postgres.sh

RUN /usr/bin/postgresql-setup initdb

ADD ./postgresql.conf /var/lib/pgsql/data/postgresql.conf

RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf

RUN echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/data/pg_hba.conf

# local access to postgres
RUN echo "local   all             postgres                                md5" >> /var/lib/pgsql/data/pg_hba.conf

VOLUME ["/var/lib/pgsql"]

EXPOSE 5432

# ======
# part 2
# ======
ENV POSTGRES_DB pgpostcode
ENV DB_NAME pgpostcode

ENV DB_USER postgres
ENV POSTGRES_USER postgres

ENV DB_PASS pgpass
ENV POSTGRES_PASSWORD pgpass

RUN yum -y install git; yum clean all
RUN yum -y install net-tools nodejs npm ogr_fdw96 postgis2_96; yum clean all
RUN yum -y install bash which; yum clean all

WORKDIR /root

RUN git clone https://github.com/catman/postcodes.io.git

RUN useradd -ms /bin/bash postcode-user

WORKDIR /root/postcodes.io

# download the data
RUN npm install

#
CMD ["/bin/bash", "/start_postgres.sh"]

USER postcode-user

