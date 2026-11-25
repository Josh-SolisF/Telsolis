# Bitácora — Proyecto Telsolis

Redes de Computadoras IC-7602 · Proyecto 2 (Central Telefónica) y Examen en Casa (PaaS.net)

Formato: una línea por actividad que impactó directamente el trabajo, con fecha
y horas invertidas. Las filas marcadas con \* tienen horas estimadas a partir
de la hora de los mensajes de trabajo; ajústenlas a lo real.
Las filas con fecha `____` deben completarse.

## Josh Solís

| Fecha | Proyecto | Actividad | Horas |
|---|---|---|---|
| 2026-11-08 | Ambos | Creación del repositorio Telsolis en GitHub con la estructura de carpetas y `.gitattributes` | ____ |
| 2026-11-09 | Ambos | Análisis de ambos enunciados y su rúbrica; selección de software, plataformas y servicios de Docker | 0.5\* |
| 2026-11-12 | PaaS | Investigación de OpenVPN TAP en Android/iOS y alternativas (dos instancias TAP/TUN, router como cliente) | 0.5\* |
| ____ | Ambos | Llave SSH en la VM docker para push a GitHub y solicitud de cuenta de estudiante | ____ |
| ____ | P2 | Creación de VM telsolis (VirtualBox, Ubuntu Server 26.04.1, red en puente) y corrección de SSH | ____ |
| ____ | P2 | Instalación de Asterisk 22.5.2 por apt y habilitación al arranque | ____ |
| ____ | PaaS | Creación de VM docker; instalación de Docker 29.1.3 y Compose 2.40.3; práctica con Nginx | ____ |
| ____ | PaaS | Servicio 1 de Compose: BIND autoritativo para telsolis.test y resolver, con `.env` y `generate-zone.sh` | ____ |
| ____ | P2 | Investigación de requisitos de registro y configuración de CallMyWay | ____ |
| 2026-11-13 | Ambos | Revisión del avance y plan de trabajo por fases | 0.25\* |
| 2026-11-13 | P2 | Estudio de conceptos de PJSIP (endpoint, auth, aor, transport) y del dialplan; redacción de `pjsip.conf` y `extensions.conf` | 0.5\* |
| 2026-11-13 | P2 | Despliegue de la configuración en la VM: generación de contraseñas, `pjsip_auth.conf` y permisos | 0.75\* |
| 2026-11-13 | P2 | Instalación y configuración de Linphone en PC (1001) e iPhone (1002); verificación de registros | 0.75\* |
| 2026-11-13 | P2 | Pruebas de la fase 1 (601, 600, llamadas 1001↔1002) y diagnóstico con la consola de Asterisk | 0.75\* |
| 2026-11-13 | P2 | Diseño y redacción de `voicemail.conf` y subrutinas de horario/buzón en `extensions.conf` | 0.5\* |
| 2026-11-13 | P2 | Despliegue del buzón; diagnóstico del choque `app_voicemail`/`app_voicemail_odbc` (`noload` en `modules.conf`) | 0.75\* |
| 2026-11-13 | P2 | Corrección del reloj de la VM (chrony) desfasado 16 min tras pausar la VM | 0.25\* |
| 2026-11-13 | P2 | Pruebas de horario automático/forzado, buzón (no contesta, cerrado) y consulta con 8500 | 0.5\* |
| 2026-11-19 | P2 | Cuarto de conferencias: `confbridge.conf` (perfiles de sala, participante y menú), extensión 8000 y pruebas | ____ |
| 2026-11-19 | P2 | Transferencias: `features.conf` (ciega `#1`, consultada `*2`), opciones `tT` en `Dial()` y pruebas | ____ |
| 2026-11-20 | P2 | Menú: contexto `menu-principal`, opción "todos", grabación de audios (9001-9003), simulación 9000 y pruebas | ____ |
| 2026-11-21 | P2 | Troncal Ring.cr: creación en el portal sip.cr, diagnóstico del servidor (IP privada vs pública) y configuración PJSIP | ____ |
| | | **Total** | **____** |

## Jesús Solís

| Fecha | Proyecto | Actividad | Horas |
|---|---|---|---|
| 2026-11-22 | PaaS | Clonación de la VM docker en otra compu; red NAT + solo-anfitrión con IP fija 192.168.56.10 (netplan) | ____ |
| 2026-11-22 | PaaS | Instalación de Docker 29.1.3 y Compose 2.40.3 (`--no-install-recommends` por error 403 del mirror) y llave SSH para GitHub | ____ |
| 2026-11-22 | PaaS | Migración del BIND (servicio 1) a la LAN 192.168.56.0/24 y pruebas con dig | ____ |
| 2026-11-23 | PaaS | Clonación de las VMs db (.11) y web (.12); DNS de la LAN apuntando al BIND y eliminación de Docker en ambas | ____ |
| 2026-11-23 | PaaS | MySQL en db: escucha en la LAN (`zz-telsolis.cnf`), base `wordpress` y usuario `wp` limitado a la VM web; pruebas de acceso | ____ |
| 2026-11-23 | PaaS | Apache + PHP en web; sitio `wordpress.conf`, descarga de WordPress e instalación conectada a db.telsolis.test | ____ |
| 2026-11-23 | PaaS | Regla NRPT en Windows para resolver `*.telsolis.test` con el BIND en cualquier red | ____ |
| 2026-11-23 | PaaS | CA propia con OpenSSL en docker (Telsolis Root CA); CSR en web, firma con SAN e instalación en Apache (443) | ____ |
| 2026-11-23 | PaaS | WordPress por HTTP y HTTPS (esquema dinámico en wp-config) e importación de la CA en Windows | ____ |
| 2026-11-23 | PaaS | Servicio 2 de Compose: Samba con imagen propia (Dockerfile sobre Ubuntu 24.04), volúmenes de datos y usuarios | ____ |
| 2026-11-23 | PaaS | Montaje CIFS permanente en web (fstab) y acceso desde el Explorador de Windows; pruebas cruzadas | ____ |
| 2026-11-23 | PaaS | Servicio 3 de Compose: ownCloud 11 (imagen oficial) con MariaDB y Redis internos; secretos en `.env`; registro DNS | ____ |
| 2026-11-23 | PaaS | Pruebas de ownCloud: subir archivos, usuario de prueba (`occ`), compartir y persistencia tras `down`/`up` | ____ |
| 2026-11-23 | PaaS | Servicio 4 de Compose: correo con docker-mailserver 16.0.1 (Postfix + Dovecot), registros A y MX, certificado de mail firmado por la CA propia | ____ |
| 2026-11-23 | PaaS | Cuentas jesus/joshua y alias postmaster; Thunderbird (IMAPS 993, submission 587); diagnóstico del asistente de Thunderbird con openssl s_client y logs | ____ |
| 2026-11-23 | PaaS | Servicio 5: DHCP con Kea 3.0.2 (imagen oficial ISC) en red interna de VirtualBox 10.20.0.0/24, network_mode host y sockets raw | ____ |
| 2026-11-23 | PaaS | Tercer adaptador (red interna) en docker y web; pruebas de préstamo y diagnóstico de client-id; respuestas del profe y decisión de ruta A | ____ |
| 2026-11-23 | PaaS | DHCP publicado para la WAN: red telsolis-wan, opción routers, docker como puerta de enlace (DOCKER-USER + NAT en servicio systemd) | ____ |
| 2026-11-23 | PaaS | VM cliente-wan (un solo adaptador); diagnóstico: netplan del instalador amarrado a la MAC original y PID viejo de Kea (tmpfs en /var/run/kea) | ____ |
| 2026-11-24 | PaaS | Registro del dominio telsolis.tech (name.com); instalación de Terraform 1.17.2, AWS CLI y Ansible; llave SSH para AWS | ____ |
| 2026-11-24 | PaaS | Código IaC de la VPN: Terraform (EC2, security group, EIP, inventario) y playbook de Ansible (OpenVPN TAP/TUN, easy-rsa, NAT, perfiles) | ____ |
| 2026-11-24 | PaaS | Glue records ns1/ns2.telsolis.tech y nameservers en name.com; BIND autoritativo en la EC2 (Ansible) | ____ |
| 2026-11-24 | PaaS | VM web como cliente VPN con IP fija 10.8.2.200; Nginx en AWS como proxy por el túnel; wp-config para telsolis.tech | ____ |
| 2026-11-24 | PaaS | Certificado de Let's Encrypt con respaldo en la VM docker; pruebas desde el celular con datos móviles | ____ |
| 2026-11-24 | PaaS | Servicio 5 de Compose: MySQL 8.4 (imagen oficial) como BD del WordPress de Kubernetes; script de inicio con usuario wpk8s limitado a la VM k8s | ____ |
| 2026-11-24 | PaaS | Registro mysql.telsolis.test y pruebas: permisos, rechazo desde web (.12) y persistencia del volumen | ____ |
| 2026-11-24 | PaaS | VM k8s (.13, clon de db) e instalación de k3s con node-ip y flannel en la LAN | ____ |
| 2026-11-24 | PaaS | Manifiestos de WordPress (Namespace, PVC, Deployment, Service, Ingress) con BD en el MySQL de Compose; Secret fuera del repo; cms.telsolis.test | ____ |
| 2026-11-24 | PaaS | Instalación de WordPress en Kubernetes; escalado a 2 réplicas y prueba de autorreparación | ____ |
| | | **Total** | **____** |
