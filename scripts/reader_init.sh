#!/bin/bash
set -e

# Запуск MySQL в фоновом режиме
docker-entrypoint.sh mysqld --server-id=2 --relay-log=mysqld-relay-bin --log-slave-updates=1 --gtid-mode=ON --enforce-gtid-consistency=ON &

echo "Initializing replication..."
until mysql -h writer_db -u root -proot_password -e "status"; do
  >&2 echo "Writer DB is unavailable - sleeping"
  sleep 1
done


# Ожидание запуска MySQL
sleep 40

# Настройка репликации
mysql -u root -proot_password <<-EOSQL
    STOP REPLICA;
    CHANGE MASTER TO MASTER_HOST='writer_db', MASTER_USER='replica_user', MASTER_PASSWORD='replica_password', MASTER_AUTO_POSITION=1;
    START SLAVE;
EOSQL

# Ждем завершения всех фоновых задач
wait
