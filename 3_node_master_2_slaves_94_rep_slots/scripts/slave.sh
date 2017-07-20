set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet

yum localinstall -y http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-3.noarch.rpm

yum install -y postgresql94 postgresql94-contrib postgresql94-server

pg_basebackup -h 192.168.4.2 -D /var/lib/pgsql/9.4/data -U rep -v -P --xlog-method=stream -R

ln -s /var/lib/pgsql/9.4/data /database
cd /database

echo "trigger_file = '/tmp/postgresql.trigger.5432'" >> /database/recovery.conf
echo "primary_slot_name = '$2'" >> /database/recovery.conf


chown postgres:postgres -R /var/lib/pgsql/9.4/data

/etc/init.d/postgresql-9.4 start
