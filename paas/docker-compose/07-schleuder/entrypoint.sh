#!/bin/bash
# Telsolis: arranque del contenedor Schleuder.
# 1) mapa de direcciones de las listas, 2) base de datos de Schleuder, 3) clave de la API,
# 4) configuración de correo saliente, 5) cliente schleuder-cli, 6) API daemon, 7) Postfix.
set -euo pipefail

echo "[telsolis] Confiar en la CA propia (TLS hacia mail.telsolis.test)"
update-ca-certificates >/dev/null

echo "[telsolis] Mapa de direcciones de las listas"
cp /config/transport_schleuder /etc/postfix/transport_schleuder
postmap /etc/postfix/transport_schleuder

echo "[telsolis] Base de datos y directorios de Schleuder"
mkdir -p /var/lib/schleuder /var/log/schleuder
schleuder install
chown -R schleuder:schleuder /var/lib/schleuder /var/log/schleuder

echo "[telsolis] Clave de la API (se genera una sola vez y queda en el volumen)"
if [ ! -s /var/lib/schleuder/api_key ]; then
  schleuder new_api_key | tr -d '[:space:]' > /var/lib/schleuder/api_key
  chmod 600 /var/lib/schleuder/api_key
fi
export API_KEY="$(cat /var/lib/schleuder/api_key)"

echo "[telsolis] Configuración: correo saliente por ${SMTP_HOST}:${SMTP_PORT} y clave de la API"
ruby -ryaml -e '
  f = "/etc/schleuder/schleuder.yml"
  c = YAML.unsafe_load_file(f) || {}
  c["smtp_settings"] ||= {}
  c["smtp_settings"]["address"] = ENV.fetch("SMTP_HOST")
  c["smtp_settings"]["port"]    = ENV.fetch("SMTP_PORT").to_i
  c["smtp_settings"]["domain"]  = "listas.telsolis.test"
  c["api"] ||= {}
  c["api"]["valid_api_keys"] = [ENV.fetch("API_KEY")]
  File.write(f, c.to_yaml)
'

echo "[telsolis] Configuración de schleuder-cli (para administrar las listas con docker exec)"
FP="$(schleuder cert fingerprint | grep -oiE '[0-9a-f]{64}' | head -1)"
mkdir -p /root/.schleuder-cli
cat > /root/.schleuder-cli/schleuder-cli.yml <<CLI
host: localhost
port: 4443
tls_fingerprint: ${FP}
api_key: ${API_KEY}
CLI
chmod 600 /root/.schleuder-cli/schleuder-cli.yml

echo "[telsolis] API de Schleuder (solo dentro del contenedor)"
su -s /bin/sh -c 'exec schleuder-api-daemon' schleuder &

echo "[telsolis] Postfix en primer plano"
exec postfix start-fg
