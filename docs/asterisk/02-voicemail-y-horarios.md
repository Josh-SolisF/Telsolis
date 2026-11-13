# Fase 2a: buzón de voz y horario de atención

Rubro: **Horarios - Voicemail (25%)**.

## Comportamiento

| Situación | Qué pasa |
|---|---|
| Fuera de horario | La llamada va directo al buzón, con el saludo de "no disponible" |
| En horario, contestan | Llamada normal |
| En horario, no contestan en 20 s o el teléfono no está conectado | Buzón, saludo de "no disponible" |
| En horario, rechazan la llamada (ocupado) | Buzón, saludo de "ocupado" |

Horario de atención: lunes a viernes de 08:00 a 17:00 (hora de Costa Rica),
definido en `[globals]` de `extensions.conf`.

Para la demostración, el horario se puede forzar desde cualquier teléfono:
**7000** automático, **7001** forzar abierto, **7002** forzar cerrado. El modo
queda guardado en la base de datos interna de Asterisk (AstDB) y sobrevive a
reinicios.

## Archivos

| Archivo | Cambio |
|---|---|
| `voicemail.conf` | Nuevo: ajustes generales del buzón |
| `voicemail_buzones.conf` | Nuevo, fuera del repo: buzones 1001 y 1002 con su PIN |
| `extensions.conf` | Subrutinas `sub-horario`, `sub-cambiar-horario`, `sub-llamar-extension`; extensiones 8500 y 7000-7002 |

## Instalación

```bash
# En Ubuntu 26.04 el buzón viene en el paquete asterisk-modules (ya instalado),
# junto a una variante ODBC. Si ambas se cargan chocan y la aplicación
# VoiceMail no queda registrada. Se desactiva la variante ODBC:
sudo sed -i '/^\[modules\]/a noload => app_voicemail_odbc.so' /etc/asterisk/modules.conf

# Zona horaria de la VM (las fechas de los mensajes la usan)
sudo timedatectl set-timezone America/Costa_Rica

sudo cp /etc/asterisk/voicemail.conf /etc/asterisk/voicemail.conf.orig
sudo cp ~/voicemail.conf ~/extensions.conf /etc/asterisk/
sudo cp ~/voicemail_buzones.conf.example /etc/asterisk/voicemail_buzones.conf
sudo nano /etc/asterisk/voicemail_buzones.conf     # cambiar los PIN
sudo chown asterisk:asterisk /etc/asterisk/voicemail*.conf /etc/asterisk/extensions.conf
sudo chmod 640 /etc/asterisk/voicemail_buzones.conf

# Reinicio completo (un reload no carga un módulo que no cargó al arrancar)
sudo systemctl restart asterisk
```

## Verificación

```
voicemail show users          # buzones 1001 y 1002 en el contexto telsolis
dialplan show internos        # deben aparecer 7000-7002 y 8500
database show telsolis        # modo actual del horario (tras marcar 700X)
```

Los mensajes se guardan en `/var/spool/asterisk/voicemail/telsolis/<buzón>/INBOX/`.

## Plan de pruebas

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | Marcar 7002 | Beep; `database show telsolis` muestra `cerrado` |
| 2 | 1001 llama a 1002 | No suena el celular; se escucha el saludo del buzón; dejar un mensaje |
| 3 | Marcar 7001 | Beep; modo `abierto` |
| 4 | 1001 llama a 1002 y nadie contesta | Suena 20 s y luego entra el buzón |
| 5 | 1001 llama a 1002 y se rechaza en el celular | Buzón con saludo de "ocupado" |
| 6 | 1001 llama a 1002 y se contesta | Llamada normal; al colgar no entra al buzón |
| 7 | Desde 1002 marcar 8500 e ingresar el PIN | Se escuchan los mensajes dejados en 2, 4 y 5 |
| 8 | Marcar 7000 | Modo automático: el resultado depende de la hora y el día |

## Problemas típicos

| Síntoma | Causa probable |
|---|---|
| `No application 'VoiceMail'` aunque `app_voicemail.so` aparece *Running* y `core show applications like Voice` da 0 | Choque con `app_voicemail_odbc.so`: agregar `noload => app_voicemail_odbc.so` en `modules.conf` y reiniciar Asterisk |
| La hora de la VM está atrasada (afecta el horario automático) | La VM se pausó o se guardó su estado. Ubuntu 26.04 usa chrony: `sudo systemctl restart chrony`. Apagar la VM en vez de guardar su estado |
| Al rechazar en el iPhone sale `CHANUNAVAIL` en vez de `BUSY` | Linphone en iOS responde con otro código al rechazar; la llamada igual va al buzón |
| `No entry in voicemail config file for '1002'` | `voicemail_buzones.conf` no existe o no se recargó el módulo |
| En modo automático siempre "fuera de horario" | Hora o día fuera del rango; revisar con `date` en la VM |
| El buzón no pide PIN y rechaza | El PIN no es numérico |
