set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet

yum localinstall -y https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-6-x86_64/pgdg-redhat10-10-1.noarch.rpm

yum install -y postgresql10 postgresql10-contrib postgresql10-server

ln -s /var/lib/pgsql/10/data /database
cd /database

/etc/init.d/postgresql-10 initdb
/etc/init.d/postgresql-10 start

sudo -u postgres -H sh -c "psql -c 'CREATE USER rep REPLICATION LOGIN CONNECTION LIMIT 2;'"

cp /vagrant/master/pg_hba.conf     /database/pg_hba.conf
cp /vagrant/master/postgresql.conf /database/postgresql.conf

chown postgres:postgres /database/pg_hba.conf
chown postgres:postgres /database/postgresql.conf

/etc/init.d/postgresql-10 restart
