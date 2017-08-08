# Dockerfile for Centos7 system with postgres >= 9.6 GPS -> postcode library on https://github.com/catman/postcodes.io
FROM david/postgresql
MAINTAINER catman@rabbich.com

# Perform updates
RUN yum -y update; yum clean all

# Install EPEL 
RUN yum -y install epel-release; yum clean all

RUN yum -y install git

# # install the postgres 
# RUN rpm -ivh https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
# RUN yum -y install postgresql96 postgresql96-server postgresql96-libs postgresql96-contrib postgresql96-devel

RUN yum -y install net-tools; yum clean all
RUN yum -y install nodejs; yum clean all
RUN yum -y install npm; yum clean all
RUN yum -y install ogr_fdw96; yum clean all
RUN yum -y install postgis2_96; yum clean all
RUN yum -y install bash; yum clean all

WORKDIR /root

RUN git clone https://github.com/catman/postcodes.io.git
ENV POSTGRES_USER postgres
ENV DB_USER username
ENV DB_PASS password
ENV DB_NAME mydb

RUN useradd -ms /bin/bash postcode-user

WORKDIR /root/postcodes.io

RUN npm install
# ENTRYPOINT ["npm run setup"]
CMD "npm run setup"

USER postcode-user

# docker run --name postgresql -d <yourname>/postgresql
