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

�������Ӹ������ǲ��ɹ���ԭ��:
#���Ӹ��Ʋ�Ҫ����

#relay-log=/opt/data/mysql/relay-log/relay-log.bin
������ᾭ����ʾ��relay-log.index  �Ҳ��� ���Բ�����д���ļ���

###################################################################################
�������ӷ������������������ȷ���裺

��1�����ڴӷ�����������
���Բ����κβ��������ӷ��������������������֮����Զ�׷���ļ�¼��
������������������д�룬flush tables with read lock��

Ȼ�������ӷ�����

�������� ��unlock tables;

��2��������������������

��������κβ����������ӷ��������ڳ�ʱʱ����������

��ȷ���������ӷ����� stop slave��

Ȼ���������� /etc/init.d/mysqld stop��

����������� ����mysql