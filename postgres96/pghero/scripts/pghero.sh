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

sudo -u postgres -H sh -c "psql -h 192.168.4.2 -Upostgres -c 'create database pgbench_db;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 pgbench_db -c 'CREATE EXTENSION pg_stat_statements;'"
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -i -U postgres -h 192.168.4.2 pgbench_db"
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -c 4 -S -t 2000 -U postgres -h 192.168.4.2 pgbench_db"
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -c 4 -t 2000 -U postgres -h 192.168.4.2 pgbench_db"


################
##pghero
################
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3001 -j ACCEPT

sudo -u postgres -H sh -c "psql -h 192.168.4.2 -Upostgres -c 'create database pghero_db;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 -c 'CREATE ROLE pghero SUPERUSER LOGIN PASSWORD '\''pghero'\'';'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 pghero_db -f /vagrant/pghero/pghero.sql"

sudo cp /vagrant/pghero/yum.conf /etc/yum.conf
sudo cp /vagrant/pghero/pghero.repo /etc/yum.repos.d/pghero.repo
sudo rpm --import https://rpm.packager.io/key
sudo yum -y install pghero

sudo pghero config:set DATABASE_URL=postgres://pghero:pghero@192.168.4.2:5432/pgbench_db
sudo pghero config:set PORT=3001
sudo pghero config:set RAILS_LOG_TO_STDOUT=disabled
sudo pghero scale web=1

sudo service pghero start

cp /vagrant/pghero/pghero.yml .
cat pghero.yml | sudo pghero run sh -c "cat > config/pghero.yml"
sudo service pghero restart

sudo pghero config:set PGHERO_STATS_DATABASE_URL=postgres://pghero:pghero@192.168.4.2:5432/pghero_db
sudo pghero run rake pghero:capture_query_stats
sudo pghero run rake pghero:capture_space_stats



####################
#Generate some workload
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -i -U postgres -h 192.168.4.2 pgbench_db"
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -c 4 -S -t 2000 -U postgres -h 192.168.4.2 pgbench_db"
sudo -su postgres -H sh -c "/usr/pgsql-9.6/bin/pgbench -c 4 -t 2000 -U postgres -h 192.168.4.2 pgbench_db"

sudo pghero run rake pghero:capture_query_stats
sudo pghero run rake pghero:capture_space_stats
####################
####################
