set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet

yum localinstall -y http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-3.noarch.rpm

yum install -y postgresql94 postgresql94-contrib postgresql94-server

ln -s /var/lib/pgsql/9.4/data /database
cd /database

/etc/init.d/postgresql-9.4 initdb
/etc/init.d/postgresql-9.4 start

sudo -u postgres -H sh -c "psql -c 'CREATE USER rep REPLICATION LOGIN CONNECTION LIMIT 4;'"


cp /vagrant/master/pg_hba.conf     /database/pg_hba.conf
cp /vagrant/master/postgresql.conf /database/postgresql.conf

chown postgres:postgres /database/pg_hba.conf
chown postgres:postgres /database/postgresql.conf

/etc/init.d/postgresql-9.4 restart

slave_list=("'slave1'" "'slave2'")

for i in "${slave_list[@]}"
  do
    echo $i
    sudo -u postgres -H sh -c "psql -c 'SELECT 1 FROM pg_create_physical_replication_slot('\''$i'\'');'"
  done

/etc/init.d/postgresql-9.4 restart
