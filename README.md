#!/bin/sh

#Script Name:pgsql_source_install.sh
#Create Date:2013-05-23
#Last Modify:2013-05-23
#Author:Jason_z
#E-mail:ccnuzxg@gmail.com

###############################################
#Description:Install Postgres By Source Code 
###############################################

vesion=9.2.3

yourDir=/data/pg_data

#download pgsql source code from http://www.postgresql.org/ftp/source/

downUrl="http://ftp.postgresql.org/pub/source/v$version/postgresql-$version.tar.bz2"

# check enviorment
yum -y install make gcc zlib-level readline-devel wget

#create pgsql group & user
groupadd postgres
useradd postgres -g postgres

#pgsql bin dir
mkdir -p /usr/local/pgsql
#pgsql data dir
mkdir -p $yourDir

chown -R postgres:postgres /usr/local/pgsql
chown -R postgres:postgres $yourDir

wget http://ftp.postgresql.org/pub/source/v$version/postgresql-$version.tar.bz2

tar jxvf postgresql-$version.tar.bz2

cd postgresql-$version

./configure --prefix=/usr/local/pgsql

make 

make install

# initdb

/usr/local/pgsql/bin/initdb --encoding=utf8 -D $yourDir

# join in startup
cp ./contrib/start-scripts/linux /etc/init.d/postgresql
chmod +x /etc/init.d/postgresql
chkconfig postgresql on

# modify config
sed -i "s/localhost/*/g" $yourDir/postgresql.conf

# start service
service postgresql start

# alert password
#sudo -u postgres psql -d postgres -c "ALTER USER postgres PASSWORD '123456';"
