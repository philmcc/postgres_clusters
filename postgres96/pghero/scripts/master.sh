set -e -u

PG_DATABASE_NAME=${1:-repl_database}
SLAVE_LIST=${2:-SLAVE_LIST}
echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet
yum localinstall -y https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum install -y postgresql96 postgresql96-contrib postgresql96-server
yum install -y -q  powa_96 pg_qualstats96 pg_stat_kcache96 hypopg_96


ln -s /var/lib/pgsql/9.6/data /database
cd /database


/usr/pgsql-9.6/bin/postgresql96-setup initdb
systemctl start postgresql-9.6.service
systemctl enable postgresql-9.6.service



sudo -u postgres -H sh -c "psql -c 'CREATE USER rep REPLICATION LOGIN CONNECTION LIMIT 4;'"

cp /vagrant/master/pg_hba.conf     /database/pg_hba.conf
cp /vagrant/master/postgresql.conf /database/postgresql.conf

chown postgres:postgres /database/pg_hba.conf
chown postgres:postgres /database/postgresql.conf

systemctl restart postgresql-9.6.service


slave_list=("'slave1'")

for i in "${slave_list[@]}"
  do
    echo $i
    sudo -u postgres -H sh -c "psql -c 'SELECT 1 FROM pg_create_physical_replication_slot('\''$i'\'');'"
  done

echo "export PATH=$PATH:/usr/pgsql-9.6/bin" >> /var/lib/pgsql/.bash_profile


systemctl restart postgresql-9.6.service
