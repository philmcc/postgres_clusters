# Hot Standby Master Slave Replication on PostgreSQL


Based on: https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps

#### Run:

It uses CentOS 6.5 as a base image https://github.com/2creatives/vagrant-centos/releases/tag/v6.5.3

```shell
vagrant box add centos65-x86_64-20140116 https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box
git clone https://github.com/philmcc/postgres_clusters.git
cd postgres_clusters/2-node-master-slave_94
vagrant up
# it can takes several minutes
```


#### Test the Replication

On master:
```sql
psql -h 192.168.4.2 -U postgres

CREATE TABLE rep_test (test varchar(40));

INSERT INTO rep_test VALUES ('data one');
INSERT INTO rep_test VALUES ('some more words');
INSERT INTO rep_test VALUES ('lalala');
INSERT INTO rep_test VALUES ('hello there');
INSERT INTO rep_test VALUES ('blahblah');
```

On slave:
```sql
psql -h 192.168.4.3 -U postgres

SELECT * FROM rep_test;

-- will show data

INSERT INTO rep_test VALUES ('oops');

ERROR:  cannot execute INSERT in a read-only transaction

```
