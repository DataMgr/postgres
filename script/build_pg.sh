#!/bin/sh

vesion=9.2.3

PG_HOME=/usr/local/pgsql
PG_DATA=/data/pg_data
wget http://ftp.postgresql.org/pub/source/v$version/postgresql-$version.tar.bz2
 
# check enviorment
yum -y install make gcc zlib-level readline-devel wget

#create pgsql group & user
groupadd postgres
useradd  postgres -g postgres

#pgsql bin dir
mkdir -p PG_HOME
#pgsql data dir
mkdir -p $PG_DATA

chown -R postgres:postgres PG_HOME
chown -R postgres:postgres $PG_DATA


tar jxvf postgresql-$version.tar.bz2
cd postgresql-$version

./configure --prefix=/usr/local/pgsql

make && make install

# initdb
PG_HOME/bin/initdb --encoding=utf8 -D $PG_DATA

# join in startup
cp ./contrib/start-scripts/linux  /etc/init.d/postgresql
chmod +x /etc/init.d/postgresql
chkconfig postgresql on

# modify config
sed -i "s/localhost/*/g" $PG_DATA/postgresql.conf

# start service
service postgresql start

# alert password
postgres psql -d postgres -c "ALTER USER postgres PASSWORD 'sfitdba';"
