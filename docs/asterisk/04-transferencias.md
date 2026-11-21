# Fase 2c: transferencias de llamadas

Rubro: **Transferencias (10%)**.

## Tipos de transferencia

| Tipo | Cómo funciona | Teclas |
|---|---|---|
| **Ciega** (*blind*) | Se marca el destino y quien transfiere sale de la llamada de inmediato. La otra persona pasa directo al destino, conteste o no | `#1` + número |
| **Consultada** (*attended*) | Quien transfiere primero habla con el destino (la otra persona queda en espera). Al colgar, se unen las otras dos | `*2` + número |

## Dos mecanismos

1. **Teclas durante la llamada (DTMF).** Asterisk escucha las teclas que se
   presionan durante la llamada y ejecuta la transferencia él mismo. Las teclas
   están en `features.conf` y solo funcionan en llamadas hechas con
   `Dial(..., tT)`:
   - `t`: quien **recibe** la llamada puede transferir.
   - `T`: quien **hace** la llamada puede transferir.
2. **Botón de transferir del softphone (SIP REFER).** Linphone envía a Asterisk
   un mensaje `REFER` ("pásale esta llamada a tal número"). No necesita
   configuración extra: lo maneja el módulo `res_pjsip_refer`. El destino se
   busca en el contexto del endpoint que transfiere (`internos`).

## Archivos

| Archivo | Cambio |
|---|---|
| `features.conf` | Nuevo: teclas `#1` y `*2`, tiempos y sonidos de la transferencia |
| `extensions.conf` | `Dial()` de `sub-llamar-extension` con las opciones `tT` y la variable `TRANSFER_CONTEXT=internos` |

## Instalación

```bash
sudo cp /etc/asterisk/features.conf /etc/asterisk/features.conf.orig
sudo cp ~/features.conf ~/extensions.conf /etc/asterisk/
sudo chown asterisk:asterisk /etc/asterisk/features.conf /etc/asterisk/extensions.conf

sudo asterisk -rx "module reload features"
sudo asterisk -rx "dialplan reload"
sudo asterisk -rx "features show"       # blindxfer = #1, atxfer = *2
```

## Plan de pruebas

Con solo dos teléfonos, el destino de la transferencia es una extensión de
servicio (601, 600 o 8000). Cuando esté CallMyWay, la demostración natural es:
una llamada externa entra por el menú, contesta la PC y la transfiere al celular.

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | 1001 llama a 1002; en el **celular** marcar `#1` y luego `601` | El celular sale de la llamada; la PC escucha "Hello world" |
| 2 | 1001 llama a 1002; en la **PC** marcar `#1` y luego `601` | La PC sale; el celular escucha "Hello world" (prueba la opción `T`) |
| 3 | 1001 llama a 1002; en el celular marcar `*2` y luego `600`; hablar en el eco y colgar el celular | Mientras tanto la PC espera; al colgar el celular, la PC queda conectada a la prueba de eco |
| 4 | 1001 llama a 1002; en Linphone de la PC usar el botón **Transferir** al número `8000` | El celular entra a la sala de conferencias (transferencia por SIP REFER) |
| 5 | Transferencia ciega a un número inexistente (por ejemplo `#1` + `555`) | Se escucha el sonido de error y la llamada original sigue |

En la consola de Asterisk (`asterisk -rvvv`) cada transferencia exitosa muestra
líneas con `Blind transfer` o `Attended transfer`.

## Problemas típicos

| Síntoma | Causa probable |
|---|---|
| Tras `#1` se escucha "transfer" y luego `Dialed no digits` en la consola | El destino se marcó durante el aviso o tardó más que `transferdigittimeout` (6 s): esperar a que termine "transfer" y marcar enseguida |
| `Dialed '6@sub-llamar-extension' does not exist` al transferir desde quien llama | Sin `TRANSFER_CONTEXT`, el destino se busca en la subrutina donde está quien llama. Se corrige con `Set(__TRANSFER_CONTEXT=internos)` antes del `Dial` |
| `#1` no hace nada | La llamada no pasó por `Dial(..., tT)`, o el teléfono no envía DTMF por RFC 4733 |
| Al marcar el destino se corta la llamada | El número no existe en el contexto `internos`; revisar `dialplan show internos` |
| El botón Transferir de Linphone falla | Revisar en la consola el `REFER`; el destino debe existir en `internos` |
| La transferencia se completa pero el destino está ocupado | En la ciega, quien fue transferido queda en el buzón o en ocupado; usar la consultada para verificar antes |
