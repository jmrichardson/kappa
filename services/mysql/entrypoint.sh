echo "create database metastore" | mysql -uroot -proot
if [ $? -ne 0 ]; then
  mysql -uroot -proot --database=metastore < /tmp/hive-schema-3.1.0.mysql.sql
fi
