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
| | | **Total** | **____** |

