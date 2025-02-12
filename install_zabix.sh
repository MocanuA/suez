#!/bin/bash

# Mettre à jour les paquets
apt update && apt upgrade -y

# Installation des paquets nécessaires
apt install -y wget mysql-server apache2

# Installation du dépôt Zabbix
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu22.04_all.deb
apt update

# Installation de Zabbix
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent2

# Configuration MySQL
mysql -uroot -e "
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
"

# Import de la base de données Zabbix
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -pzabbix zabbix

# Désactivation de log_bin_trust_function_creators
mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Configuration du mot de passe dans Zabbix
sed -i "s/# DBPassword=/DBPassword=zabbix/g" /etc/zabbix/zabbix_server.conf

# Redémarrage des services
systemctl restart zabbix-server zabbix-agent2 apache2
systemctl enable zabbix-server zabbix-agent2 apache2

# Message de fin
echo "Zabbix est installé ! Accédez à http://$(hostname -I | awk '{print $1}')/zabbix"
