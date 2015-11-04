#!/bin/bash
##SCRIPT:install_mysql.sh
##AUTHOR:knight
##DATE:2015-6-23
##ָ����Ҫ�趨��ֵ
user=mysql
group=mysql
install_dir=/usr/local/mysql
source_file=Percona-Server-5.5.27-rel29.0.tar.gz
tar_dir=$( echo "$source_file" | sed 's/\.tar.gz//g')


#####################
###��ʼ��װ
#####################
echo "`date +%Y-%m-%d\ %H:%M:%S` start install_mysql"
logger "`date +%Y-%m-%d\ %H:%M:%S` start install_mysql"

linux_type=`cat /etc/issue | head -1 | awk '{print tolower($1)}'`
cmake=`which cmake`
if [ ${linux_type} == "ubuntu" ]
then
	chg_unix_comm=fromdos
	if [ ! -x /usr/bin/fromdos ]
	then
		apt-get update
		apt-get install -y tofrodos
	fi
	apt-get install -y libncurses5-dev bison make g++ gcc unzip cmake
	if [ ! -x ${cmake} ]
	then
		apt-get install -y cmake
	fi
elif [ ${linux_type} == "red" -o ${linux_type} == "centos" ]
then
	chg_unix_comm=dos2unix
	if [ ! -x /usr/bin/dos2unix ]
	then
		yum install -y dos2unix
	fi
	yum install -y bison ncurses ncurses-devel gcc gcc-c++ make unzip openssl openssl-devel cmake
	if [ ! -x ${cmake} ]
	then
		yum install -y cmake
	fi
fi

if [ ! -d /opt/mysql ]
then
	mkdir -p /opt/mysql
fi

#���ذ�װ����ָ��Ŀ¼
mkdir -p /opt/soft
cd /opt/soft
#git clone  ......./packages.zip

unzip packages.zip

cd ./packages

##����û����û���

groupadd ${group} 2>/dev/null
USER=$(grep  "${user}" /etc/passwd | wc -l)
#echo "$USER"
if [ ${USER} -ne 0 ]
then
        echo "user $user exist! we will change it into $group"
        usermod -g $group $user
else
        useradd -g $group $user
fi

##������װ�����Ŀ¼
mkdir -p /data/dbdata/mysqldata
mkdir -p /data/dbdata/mysqldata/tmp
mkdir -p /data/dbdata/mysqllog
mkdir -p /data/dbdata/mysqllog/binlog
mkdir -p /data/dbdata/mysqllog/relay-log

test -d $install_dir || mkdir  $install_dir

if [ -f ${source_file} ]
then
        echo "going to untar the ${source_file}"
else
        echo -e "Percona-Server*.tar.gz file not exists! \c Please check it."
        exit 2
fi

##��ѹԴ���ļ���
tar -zxvf $source_file >/dev/null 2>&1
echo "tar success!"


##����Դ��
cd $tar_dir

echo "going to configure,please wait......"

cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/dbdata/mysqldata -DWITH_EXTRA_CHARSETS=complex -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_DEBUG=0 -DWITH_SSL=bundled -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1

if [ $? -ne 0 ];then
	echo "configure filed ,please check it out"
	exit 1
fi

##��װmysql
echo "make mysql, please wait for 20 minutes"

make

if [ $? -ne 0 ];then
        echo "make filed ,please check it out"
        exit 1
fi

make install

cd ../

##�޸�Ŀ¼Ȩ��
chown -R mysql:mysql $install_dir
chown -R mysql:mysql /data/dbdata/

##ָ�������ļ���ʹ��zip�����my.cnf
cp ..../my.cnf /etc/

#mem=`free -m|grep Mem|awk '{print $2}'`
#if [ ${mem} -lt 1024 ]
#then
#	sed -i 's/^innodb_buffer_pool_size.*$/innodb_buffer_pool_size=128M/g' /etc/my.cnf
#fi

##��ʼ��db
cp /usr/local/mysql/scripts/mysql_install_db /usr/local/mysql/bin/

#####
#or /usr/local/mysql/scripts/mysql_install_db --defaults-file=/usr/local/mysql/etc/my.cnf --user=mysql --datadir=/data/dbdata/mysqldata --basedir=/usr/local/mysql
#####

cd /usr/local/mysql

./bin/mysql_install_db  --defaults-file=/etc/my.cnf  --user="$user"

##�趨mysqlΪ������
cp /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld

if [ ${linux_type} == "ubuntu" ]
then
	update-rc.d mysqld defaults
	ln -s  /usr/local/mysql/lib/libmysqlclient.so.18 /lib/x86_64-linux-gnu/libmysqlclient.so.18
elif [ ${linux_type} == "red" -o ${linux_type} == "centos" ]
then
	chkconfig --add mysqld
	chkconfig --level 2345 mysqld on
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
fi

#echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
ln -s /usr/local/mysql/bin/* /usr/local/bin/
if [ $? != 0 ]
then
	ln -s /usr/local/mysql/bin/* /usr/bin/
fi

##����mysql
echo "mysql starting"

/etc/init.d/mysqld start

if [ $? -ne 0 ];then
	echo "mysql start filed ,please check it out"
else
	echo "mysql start successful,congratulations"
	echo "delete from mysql.user where host != 'localhost' or user !='root';" | /usr/local/mysql/bin/mysql
fi

##��װ���
logger "`date +%Y-%m-%d\ %H:%M:%S` Install_mysql over"
echo "`date +%Y-%m-%d\ %H:%M:%S` Install_mysql over"

exit 0
