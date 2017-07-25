set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet

yum localinstall -y https://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm

yum install -y postgresql96 postgresql96-contrib postgresql96-server

pg_basebackup -h 192.168.4.2 -D /var/lib/pgsql/9.6/data -U rep -v -P --xlog-method=stream -R

ln -s /var/lib/pgsql/9.6/data /database
cd /database

echo "trigger_file = '/tmp/postgresql.trigger.5432'" >> /database/recovery.conf
echo "primary_slot_name = '$2'" >> /database/recovery.conf


chown postgres:postgres -R /var/lib/pgsql/9.6/data

echo "export PATH=$PATH:/usr/pgsql-9.6/bin" >> /var/lib/pgsql/.bash_profile 

/etc/init.d/postgresql-9.6 start
