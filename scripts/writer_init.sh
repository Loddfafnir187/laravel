#!/bin/bash
set -e

# Запуск MySQL в фоновом режиме
docker-entrypoint.sh mysqld --server-id=1 --log-bin=mysql-bin --binlog-do-db=writer_db --gtid-mode=ON --enforce-gtid-consistency=ON &

# Ожидание запуска MySQL
sleep 30

# Настройка пользователя репликации
mysql -u root -proot_password <<-EOSQL
    CREATE USER IF NOT EXISTS 'replica_user'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'replica_password';
    GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';
    FLUSH PRIVILEGES;
EOSQL

# Ждем завершения всех фоновых задач
wait
