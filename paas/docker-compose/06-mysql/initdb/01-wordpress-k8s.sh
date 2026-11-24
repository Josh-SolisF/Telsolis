#!/bin/bash
# Telsolis: base y usuario del WordPress de Kubernetes (VM k8s, 192.168.56.13).
# Lo ejecuta la imagen oficial de MySQL solo al inicializar el volumen por primera vez.
# El usuario solo puede conectarse desde la VM k8s y solo tiene permisos sobre su base.
set -e
mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS wordpress_k8s CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wpk8s'@'192.168.56.13' IDENTIFIED BY '${WPK8S_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress_k8s.* TO 'wpk8s'@'192.168.56.13';
FLUSH PRIVILEGES;
SQL
