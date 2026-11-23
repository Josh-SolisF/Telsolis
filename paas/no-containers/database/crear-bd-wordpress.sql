-- Telsolis: base y usuario de WordPress en la VM db (192.168.56.11)
-- Uso: reemplazar CAMBIAR_CONTRASENA (generada con `openssl rand -base64 18`)
--      y ejecutar con: sudo mysql < crear-bd-wordpress.sql
-- El usuario wp solo puede conectarse desde la VM web (192.168.56.12)
-- y solo tiene permisos sobre la base wordpress.

CREATE DATABASE wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wp'@'192.168.56.12' IDENTIFIED BY 'CAMBIAR_CONTRASENA';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp'@'192.168.56.12';
FLUSH PRIVILEGES;
