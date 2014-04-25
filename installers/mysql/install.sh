#!/bin/bash
#######################################################################
#
#	Debian/Ubuntu Installer MySQL 
#
######################################################################

sudo -i

# MYSQL ===========================================================
export DEBIAN_FRONTEND=noninteractive

MYSQL_USER_ADMIN='vagrant'
MYSQL_PASSWORD=123456789
MYSQL_DBNAME='vagrant'
MYSQL_PORT=3306
MYSQL_USER='mysql'
MYSQL_KEY_BUFFER='128M'
MYSQL_MAX_CONNECTIONS=1000

debconf-set-selections <<< 'mysql-server mysql-server/root_password password $MYSQL_PASSWORD'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD'

apt-get install -y mysql-server mysql-client mysql-common
/etc/init.d/mysql start

mysql -uroot -p$MYSQL_PASSWORD -e "CREATE USER '$MYSQL_USER_ADMIN'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE '$MYSQL_DBNAME' DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL ON '$MYSQL_DBNAME' TO '$MYSQL_USER_ADMIN'@'localhost';"

MYSQL_CNF<<EOF
#
# REFERENCIA
# @link http://www.vivaolinux.com.br/etc/my.cnf-fabio
# @link http://www.fromdual.com/mysql-configuration-file-sample
#

[client]
port			= $MYSQL_PORT
socket			= /var/run/mysqld/mysqld.sock
 
[safe_mysqld]
err-log			= /var/log/mysql/mysql.err
 
[mysqld]
server-id		= 10
log-bin			= /var/log/mysql/mysql-bin.log
binlog-do-db		= pop
binlog-ignore-db	= mailstats,mysql,pop.bak,radius,radius.bak,test
 
user      		= $MYSQL_USER
pid-file   		= /var/run/mysqld/mysqld.pid
socket      		= /var/run/mysqld/mysqld.sock
port      		= $MYSQL_PORT
log      		= /var/log/mysql.log
basedir      		= /usr
datadir      		= /var/lib/mysql
tmpdir      		= /tmp
language   		= /usr/share/mysql/english
skip-locking

max_allowed_packet	= 16M
default_storage_engine	= InnoDB
character_set_server	= utf8
collation_server	= utf8_general_ci

query_cache_type	= 1
query_cache_size	= 64M


# key-buffer define quanto de memória será armazenado para
# gravar dados de consultas do MySQL. Quanto maior a quantidade
# de memória disponível, melhor será o desempenho do servidor
# exemplo key_buffer= 312M


set-variable    	= key_buffer= $MYSQL_KEY_BUFFER
 
set-variable    	= max_allowed_packet=1M
 
# table_cache é muito importante, este número deve ser o dobro
# do número definido pela variável max_connections
set-variable    	= table_cache=20000
 
set-variable    	= sort_buffer=1M
set-variable    	= record_buffer=1M
set-variable    	= myisam_sort_buffer_size=64M
set-variable    	= thread_cache=8
set-variable    	= thread_concurrency=8
 
# max_connections vai definir quantos sub-processos e
# consequentemente quantas conexões seu MySQL suportará
# simultaneamente. Por incrível que pareça, quanto maior este
# número, menor será o load do seu server. Tente restringir este
# para um número baixo e você verá que loucura está fazendo
# exemplo max_connections=10000

set-variable    	= max_connections=$MYSQL_MAX_CONNECTIONS
 
set-variable    	= net_write_timeout=30
set-variable    	= connect_timeout=2
set-variable    	= wait_timeout=30
 
# Read the manual if you want to enable InnoDB!
skip-innodb
 
[mysqldump]
quick
set-variable   		= max_allowed_packet=1M
 
[mysql]
 
[isamchk]
set-variable   		= key_buffer=64M # era 16M
EOF

echo $MYSQL_CNF > /etc/my.cnf
echo $MYSQL_CNF > /etc/mysql/my.cnf

/etc/init.d/mysql restart

exit
