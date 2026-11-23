# Telsolis: imagen propia de Samba (servidor de archivos SMB)
FROM ubuntu:24.04
RUN apt-get update \
 && apt-get install -y --no-install-recommends samba \
 && rm -rf /var/lib/apt/lists/*
# Usuario dueño de la carpeta compartida (sin shell ni home: solo para Samba)
RUN useradd -M -s /usr/sbin/nologin telsolis-smb \
 && mkdir -p /srv/compartido \
 && chown telsolis-smb:telsolis-smb /srv/compartido
EXPOSE 445
CMD ["smbd", "--foreground", "--no-process-group", "--debug-stdout"]
