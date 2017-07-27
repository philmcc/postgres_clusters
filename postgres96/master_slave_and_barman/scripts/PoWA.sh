set -e -u

PG_DATABASE_NAME=${1:-repl_database}

echo "Installing utils..."

echo "exclude=mirror.smartmedia.net.id, kartolo.sby.datautama.net.id" >> /etc/yum/pluginconf.d/fastestmirror.conf

yum install -y -q atool wget ping nano telnet
yum localinstall -y https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum install -y postgresql96 postgresql96-contrib postgresql96-server
yum install -y https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/powa_96-3.1.0-4.rhel7.x86_64.rpm
yum install -y https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/powa_96-web-3.1.0-4.rhel7.x86_64.rpm


ln -s /var/lib/pgsql/9.6/data /database
cd /database

chown postgres:postgres -R /var/lib/pgsql/9.6/data

echo "export PATH=$PATH:/usr/pgsql-9.6/bin" >> /var/lib/pgsql/.bash_profile


cp /vagrant/PoWA/powa-web.conf /etc/powa-web.conf

sudo -u postgres -H sh -c "psql -h 192.168.4.2 -c 'CREATE ROLE powa SUPERUSER LOGIN PASSWORD '\''pass'\'';'"
#sudo -u postgres -H sh -c "psql -c 'CREATE ROLE powa SUPERUSER LOGIN PASSWORD '\''pass'\'';'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 -c 'CREATE DATABASE powa;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 powa -c 'CREATE EXTENSION pg_stat_statements;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 powa -c 'CREATE EXTENSION btree_gist;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 powa -c 'CREATE EXTENSION powa;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 powa -c 'CREATE EXTENSION pg_qualstats;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 powa -c 'CREATE EXTENSION pg_stat_kcache;'"
sudo -u postgres -H sh -c "psql -h 192.168.4.2 powa -c 'CREATE EXTENSION hypopg;'"


iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8888 -j ACCEPT

#powa-web
