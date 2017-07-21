set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet

yum localinstall -y https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-6-x86_64/pgdg-redhat10-10-1.noarch.rpm

yum install -y postgresql10 postgresql10-contrib postgresql10-server

pg_basebackup -h 192.168.4.2 -D /var/lib/pgsql/10/data -U rep -v -P --wal-method=stream -R

ln -s /var/lib/pgsql/10/data /database
cd /database

echo "trigger_file = '/tmp/postgresql.trigger.5432'" >> /database/recovery.conf
echo "primary_slot_name = '$2'" >> /database/recovery.conf


chown postgres:postgres -R /var/lib/pgsql/10/data

/etc/init.d/postgresql-10 start
