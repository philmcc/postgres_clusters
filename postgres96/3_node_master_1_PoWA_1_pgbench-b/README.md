This is a vagrant config that sets up 4 nodes:
 a Postgres 9.6 master and slave cluster
 1 node running pgbench to create some load on the cluster
 1 node that runs PoWA3 Web. PoWA is also installed and configured on the cluster


#### Run:

It uses CentOS 6.5 as a base image https://github.com/2creatives/vagrant-centos/releases/tag/v6.5.3

```shell
vagrant box add centos65-x86_64-20140116 https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box
git clone https://github.com/philmcc/postgres_clusters.git
cd postgres_clusters/postgres94/3_node_master_1_PoWA_1_pgbench
vagrant up
```


pgbench is installed on the node 'pgbench'
Access it by typing
  vagrant ssh pgbench
  sudo su - postgres  
Then run it with a command like:
  /usr/pgsql-9.6/bin/pgbench -c 4 -t 2000 -U postgres -h 192.168.4.2 pgbench_db
  See more at https://www.postgresql.org/docs/devel/static/pgbench.html


PoWA is running on the master already but to connect to the web interface, connect to the PoWA node:
  vagrant ssh PoWA
  powa-web

You should then be able to acess the GUI from a browser at localhost:8881
