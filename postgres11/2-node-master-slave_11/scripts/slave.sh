set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet

yum localinstall -y https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-6.5-x86_64/pgdg-centos11-11-2.noarch.rpm

yum install -y postgresql11 postgresql11-contrib postgresql11-server

pg_basebackup -h 192.168.4.2 -D /var/lib/pgsql/11/data -U rep -v -P --wal-method=stream -R

ln -s /var/lib/pgsql/11/data /database
cd /database

echo "trigger_file = '/tmp/postgresql.trigger.5432'" >> /database/recovery.conf

chown postgres:postgres -R /var/lib/pgsql/11/data

/etc/init.d/postgresql-11 start
