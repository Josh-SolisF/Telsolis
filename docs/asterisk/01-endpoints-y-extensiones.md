# Fase 1: endpoints y llamadas internas

Objetivo: que la PC (1001) y el celular (1002) se registren en Asterisk y se
llamen entre sí por la LAN. Cubre los rubros **Endpoints (5%)** y
**Extensiones (5%)**, y es la base de todo lo demás.

## Conceptos

**SIP vs RTP.** SIP (puerto 5060/UDP) es la *señalización*: registrarse,
invitar a una llamada, colgar. El audio viaja aparte, por **RTP**, en puertos
UDP altos (10000-20000 en Asterisk). Por eso una llamada puede "conectar" y
quedar muda: SIP funcionó pero RTP no.

**Registro.** El softphone envía `REGISTER` con usuario y contraseña. Asterisk
responde `401` con un desafío (digest), el teléfono repite con la respuesta y
Asterisk responde `200 OK` y anota en el **AOR** la IP:puerto del teléfono.

**Llamada.** El teléfono A envía `INVITE` a Asterisk. Asterisk busca la
extensión marcada en el **contexto** del endpoint (`context=internos`) dentro
de `extensions.conf`, ejecuta `Dial(PJSIP/1002)`, envía su propio `INVITE` al
teléfono B y une los dos canales (un *bridge*).

| Archivo | Responde a |
|---|---|
| `pjsip.conf` | ¿Quién puede conectarse y cómo? (transport, endpoint, auth, aor) |
| `extensions.conf` | ¿Qué pasa cuando alguien marca un número? (dialplan) |

## Instalación de los archivos en la VM

```bash
# En la VM telsolis, con el repo clonado en ~/Telsolis
sudo cp /etc/asterisk/pjsip.conf      /etc/asterisk/pjsip.conf.orig
sudo cp /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf.orig

sudo cp ~/Telsolis/asterisk/config/pjsip.conf      /etc/asterisk/
sudo cp ~/Telsolis/asterisk/config/extensions.conf /etc/asterisk/
sudo cp ~/Telsolis/asterisk/config/pjsip_auth.conf.example /etc/asterisk/pjsip_auth.conf
sudo nano /etc/asterisk/pjsip_auth.conf        # poner contraseñas reales
sudo chown asterisk:asterisk /etc/asterisk/*.conf
sudo chmod 640 /etc/asterisk/pjsip_auth.conf

sudo asterisk -rx "core reload"
```

Si `ufw` está activo: `sudo ufw allow 5060/udp && sudo ufw allow 10000:20000/udp`.

## Verificación en la consola de Asterisk

```bash
sudo asterisk -rvvv
```

```
pjsip show transports        # debe aparecer transport-udp en 0.0.0.0:5060
pjsip show endpoints         # 1001 y 1002 (Unavailable hasta que se registren)
pjsip show contacts          # IP:puerto de cada teléfono registrado
dialplan show internos       # extensiones 600, 601 y _100[1-2]
pjsip set logger on          # ver los mensajes SIP en vivo
```

Para ver el flujo SIP gráficamente: `sudo apt install sngrep && sudo sngrep`.

## Configuración de Linphone

En ambos dispositivos: *Usar una cuenta SIP* (cuenta de terceros, no la de
linphone.org).

| Campo | PC | Celular |
|---|---|---|
| Usuario | 1001 | 1002 |
| Contraseña | la de `pjsip_auth.conf` | la de `pjsip_auth.conf` |
| Dominio | 192.168.40.170 | 192.168.40.170 |
| Transporte | UDP | UDP |

El celular debe estar en el mismo Wi-Fi que la VM (la VM está en modo puente).

## Plan de pruebas

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | `pjsip show contacts` tras configurar ambos | 1001 y 1002 en estado *Avail* |
| 2 | Desde 1001 marcar 601 | Se escucha "Hello world" |
| 3 | Desde 1001 marcar 600 | Se escucha la propia voz (audio en ambos sentidos) |
| 4 | Repetir 2 y 3 desde 1002 | Igual |
| 5 | 1001 llama a 1002 | Suena el celular; al contestar hay audio en ambos lados |
| 6 | 1002 llama a 1001 | Igual |
| 7 | 1001 llama a 1002 y no contesta | Tras 20 s cuelga; consola muestra `NOANSWER` |

## Problemas típicos

| Síntoma | Causa probable |
|---|---|
| Linphone: "Registro fallido" / 401 en bucle | Contraseña o usuario mal; revisar `pjsip_auth.conf` y recargar |
| `No matching endpoint found` en la consola | El usuario del softphone no coincide con ningún endpoint |
| Llamada conecta pero sin audio | RTP bloqueado (ufw) o códec: dejar PCMU/PCMA activos en Linphone |
| Llamada conecta y se corta a los ~30 s | El ACK no llega: revisar NAT/IP del softphone |
| `Extension not found in context internos` | Recargar el dialplan: `dialplan reload` |
