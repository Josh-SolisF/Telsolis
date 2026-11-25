# Telsolis: Encrypted Mail List Server (Schleuder) - imagen propia
# Debian 13 (trixie) trae los paquetes oficiales de Schleuder 5 (no existe imagen oficial en Docker Hub).
# Postfix recibe el correo de las listas por SMTP (puerto 25) y se lo pasa a "schleuder work".
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections \
 && echo "postfix postfix/mailname string listas.telsolis.test" | debconf-set-selections \
 && apt-get update \
 && apt-get install -y --no-install-recommends schleuder schleuder-cli postfix ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Postfix: solo acepta las direcciones de las listas y las entrega a Schleuder por un "pipe".
#  - sin chroot (dentro de un contenedor no aporta y complica la resolución de nombres)
#  - relay_recipient_maps: rechaza cualquier dirección que no sea de una lista
#  - schleuder_destination_recipient_limit = 1: Schleuder procesa un destinatario por mensaje
RUN postconf -F '*/*/chroot = n' \
 && postconf -e 'myhostname = listas.telsolis.test' \
                'mydomain = listas.telsolis.test' \
                'myorigin = $myhostname' \
                'mydestination =' \
                'relay_domains = listas.telsolis.test' \
                'relay_recipient_maps = hash:/etc/postfix/transport_schleuder' \
                'transport_maps = hash:/etc/postfix/transport_schleuder' \
                'schleuder_destination_recipient_limit = 1' \
                'inet_interfaces = all' \
                'inet_protocols = ipv4' \
                'mynetworks = 127.0.0.0/8' \
                'smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination' \
                'maillog_file = /dev/stdout' \
                'smtpd_tls_security_level = none' \
 && postconf -M 'schleuder/unix=schleuder unix - n n - - pipe flags=DRhu user=schleuder argv=/usr/bin/schleuder work ${recipient}'

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 25
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
