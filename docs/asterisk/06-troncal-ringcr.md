# Fase 3: troncal SIP con Ring.cr

Rubros: **Rutas de entrada (5%)** y **Rutas de salida (5%)**. También completa el
**Menú (25%)**, que ahora lo escucha quien llama al número público.

## Cómo funciona

```
Teléfono cualquiera ──► red telefónica ──► Ring.cr ──internet──► Asterisk ──► menu-principal
1001 marca 8 dígitos ──► Asterisk ──internet──► Ring.cr ──► red telefónica ──► destino
```

La troncal es de tipo **registro**: Asterisk se registra en Ring.cr con usuario y
contraseña, igual que un teléfono se registra en Asterisk. Las llamadas entrantes
llegan por esa misma conexión, por lo que funciona detrás de NAT sin IP pública fija.

| Dato | Valor |
|---|---|
| Servidor SIP | `148.227.162.40:5060` (UDP) |
| Usuario | `dc768caf` |
| Contraseña | En `pjsip_auth.conf`, fuera del repositorio |
| Códecs | G.711 (`ulaw`, `alaw`) |
| DTMF | RFC 2833 / 4733 |
| Canales | 1 (una llamada externa a la vez) |

El portal de sip.cr indica el servidor `10.10.1.26`, que es una dirección privada
y no se alcanza desde internet. Ring.cr confirmó por correo que se debe usar
`148.227.162.40`.

## Configuración en el portal de sip.cr

1. **New trunk** → *A PBX* → *Registers to us* → nombre `telsolis`, 1 canal,
   **Enable NAT support** marcado.
2. **Get a number** y asignarlo a la troncal.

## Archivos

| Archivo | Cambio |
|---|---|
| `pjsip.conf` | Troncal `ringcr`: endpoint, aor, identify y registration |
| `pjsip_auth.conf` | Objeto `ringcr-auth` con el usuario y la contraseña (solo en la VM) |
| `extensions.conf` | Contexto `desde-ringcr` (todo al menú), llamadas salientes `_[2-8]XXXXXXX` y subrutina `sub-llamar-afuera`; variable `NUMERO_PUBLICO` |

### Objetos PJSIP de la troncal

| Objeto | Función |
|---|---|
| `registration` | Asterisk se registra en Ring.cr y renueva el registro cada 2 minutos |
| `endpoint` | Códecs, DTMF, NAT y contexto de las llamadas entrantes (`desde-ringcr`) |
| `aor` | Dirección fija del proveedor; `qualify` mantiene abierta la ruta por el NAT |
| `identify` | Reconoce como de la troncal las llamadas que llegan desde `148.227.162.40` |
| `outbound_auth` | Credenciales que Asterisk **entrega** al proveedor (al revés que con los teléfonos) |

### Llamadas salientes

Desde 1001 o 1002 se marca el número nacional de 8 dígitos. Asterisk lo envía en
formato **E.164** (`+506` + número), como pide Ring.cr:

```
88887777  →  Dial(PJSIP/+50688887777@ringcr)
```

Solo el contexto `internos` puede hacer llamadas salientes. Las llamadas que
entran por la troncal solo llegan al menú, y en el menú quien llama no puede
transferir (`Dial` con opción `t`).

## Instalación

En la VM, agregar al final de `/etc/asterisk/pjsip_auth.conf`:

```ini
[ringcr-auth]
type=auth
auth_type=userpass
username=dc768caf
password=CONTRASEÑA_DE_LA_TRONCAL
```

```bash
sudo cp ~/pjsip.conf ~/extensions.conf /etc/asterisk/
sudo chown asterisk:asterisk /etc/asterisk/pjsip.conf /etc/asterisk/extensions.conf
sudo asterisk -rx "pjsip reload"
sudo asterisk -rx "dialplan reload"
sudo asterisk -rx "pjsip show registrations"    # debe decir Registered
```

Cuando el número esté asignado, escribirlo en `NUMERO_PUBLICO` de `[globals]`
(formato `+506XXXXXXXX`) y recargar el dialplan.

## Plan de pruebas

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | `pjsip show registrations` | `ringcr` en estado **Registered** |
| 2 | `pjsip show contacts` | `ringcr/sip:148.227.162.40:5060` en estado **Avail** |
| 3 | Desde 1001 marcar el celular personal (8 dígitos) | Suena el celular; al contestar hay audio en ambos sentidos |
| 4 | Desde un celular cualquiera, llamar al número de Ring.cr | Se escucha el menú |
| 5 | En esa llamada, marcar `2` | Suena el 1002 (Linphone del celular) |
| 6 | En esa llamada, marcar `1` | Suenan 1001 y 1002 |
| 7 | Con el horario cerrado (7002), llamar al número y marcar `3` | Buzón del 1001 |
| 8 | Llamada entrante contestada en 1001 y transferida con `#1` + `1002` | Pasa al celular |

## Problemas típicos

| Síntoma | Causa probable |
|---|---|
| `Rejected` o `Unregistered` en `pjsip show registrations` | Usuario o contraseña incorrectos en `ringcr-auth` |
| Se queda en `Trying` | No se alcanza el servidor: revisar `ping 148.227.162.40` y la salida a internet |
| Las llamadas entrantes no llegan al menú | Número no asignado a la troncal en el portal, o la llamada no coincide con `identify` |
| Hay llamada pero no hay audio | NAT: revisar *Enable NAT support* en el portal y que `direct_media=no` |
| La llamada saliente da `CHANUNAVAIL` | La troncal no está registrada, o ya hay otra llamada externa usando el único canal |
| El número de destino está mal | Marcar 8 dígitos sin espacios ni 506; Asterisk agrega `+506` |
