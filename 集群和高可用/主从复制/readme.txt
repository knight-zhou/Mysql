##��������ļ������Ӹ��������ļ������������ļ�ֻ��id��ͬ������һ�����������ļ�����lock�޸�
##
#
#

##���������������ļ��뿴����
#��ʼ�������£�
/usr/local/mysql/scripts/mysql_install_db --defaults-file=/usr/local/mysql/etc/my.cnf --user=mysql --datadir=/data/dbdata/mysqldata --basedir=/usr/local/mysql

#�������ļ�������Ϊ�°�װmysql��ָ��

���Ӹ����������£�

����master:
grant replication slave on *.* to 'beifen'@'%' identified by '123';

show master status;

���ڴӿ⣺
stop slave;
change master to master_host='192.168.2.5',master_user='beifen',master_password='123',master_log_file='mysql-bin.000001',master_log_pos=107;
start slave;

show slave status\G;

�������⣺
show binlog events\G;

show processlist;