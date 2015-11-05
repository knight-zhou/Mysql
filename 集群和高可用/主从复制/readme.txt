##这个配置文件是主从复制配置文件，主从配置文件只是id不同其他都一样。此配置文件根据lock修改
##
#
#

##生产环境的配置文件请看生产
#初始化表如下：
/usr/local/mysql/scripts/mysql_install_db --defaults-file=/usr/local/mysql/etc/my.cnf --user=mysql --datadir=/data/dbdata/mysqldata --basedir=/usr/local/mysql

#此配置文件可以作为新安装mysql的指南

主从复制配置如下：

对于master:
grant replication slave on *.* to 'beifen'@'%' identified by '123';

show master status;

对于从库：
stop slave;
change master to master_host='192.168.2.5',master_user='beifen',master_password='123',master_log_file='mysql-bin.000001',master_log_pos=107;
start slave;

show slave status\G;

对于主库：
show binlog events\G;

show processlist;