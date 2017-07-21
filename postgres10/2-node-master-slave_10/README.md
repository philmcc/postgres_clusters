# Hot Standby Master Slave Replication on PostgreSQL


Based on: https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps

#### Run:

It uses CentOS 6.5 as a base image https://github.com/2creatives/vagrant-centos/releases/tag/v6.5.3

```shell
vagrant box add centos65-x86_64-20140116 https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box
git clone https://github.com/philmcc/postgres_clusters.git
cd postgres_clusters/postgres10/2-node-master-slave_10
vagrant up
# it can takes several minutes
```
