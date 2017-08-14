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

################
##pghero
################
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3001 -j ACCEPT
sudo -u postgres -H sh -c "psql -h 192.168.4.2 -Upostgres -c 'create database pgbench_db;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 pgbench_db -c 'CREATE EXTENSION pg_stat_statements;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 -Upostgres -c 'create database pghero_db;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 -c 'CREATE ROLE pghero SUPERUSER LOGIN PASSWORD '\''pghero'\'';'"

psql -Upostgres pghero_db -f /vagrant/pghero/pghero.sql

sudo cp /vagrant/pghero/yum.conf /etc/yum.conf
sudo cp /vagrant/pghero/pghero.repo /etc/yum.repos.d/pghero.repo
sudo rpm --import https://rpm.packager.io/key
sudo yum -y install pghero

sudo pghero config:set DATABASE_URL=postgres://pghero:pghero@localhost:5432/pgbench_db
sudo pghero config:set PORT=3001
sudo pghero config:set RAILS_LOG_TO_STDOUT=disabled
sudo pghero scale web=1

sudo service pghero status
sudo service pghero start

cp /vagrant/pghero/pghero.yml .
cat pghero.yml | sudo pghero run sh -c "cat > config/pghero.yml"
sudo service pghero restart

sudo pghero config:set PGHERO_STATS_DATABASE_URL=postgres://pghero:pghero@localhost:5432/pghero_db
sudo pghero run rake pghero:capture_query_stats
sudo pghero run rake pghero:capture_space_stats
