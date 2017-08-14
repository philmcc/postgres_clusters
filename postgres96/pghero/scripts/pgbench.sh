set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet

yum localinstall -y https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm

yum install -y postgresql96 postgresql96-contrib postgresql96-server


ln -s /var/lib/pgsql/9.6/data /database
cd /database

chown postgres:postgres -R /var/lib/pgsql/9.6/data

echo "export PATH=$PATH:/usr/pgsql-9.6/bin" >> /var/lib/pgsql/.bash_profile

##sudo -u postgres -H sh -c "psql -h 192.168.4.2 -Upostgres -c 'create database pgbench_db;'"

sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -i -U postgres -h 192.168.4.2 pgbench_db"
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -c 4 -S -t 2000 -U postgres -h 192.168.4.2 pgbench_db"
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -c 4 -t 2000 -U postgres -h 192.168.4.2 pgbench_db"
