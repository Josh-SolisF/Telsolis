# Fase 2d: menú de la llamada entrante

Rubro: **Menú (25%)**.

## Comportamiento

Cuando alguien llama al número de CallMyWay (fase 3), escucha el menú y puede:

| Marca | Qué pasa |
|---|---|
| `1001` o `1002` | Llama directamente a esa extensión |
| `1` | Suenan todos los teléfonos a la vez; contesta el primero |
| `2` | Llama al celular (1002) |
| `3` | Llama a la computadora (1001) |
| Algo que no existe | "Opción inválida" y se repite el menú |
| Nada en 5 segundos | Se repite el menú |
| 3 intentos sin una opción válida | Despedida y se cuelga |

Todas las opciones usan la misma lógica de horario y buzón que las llamadas
internas. Fuera de horario la llamada va directo al buzón. Con la opción 1, si
nadie contesta, el mensaje se guarda en los buzones de 1001 y 1002.

Quien llama desde afuera **no** puede transferir: en el menú `Dial()` usa solo la
opción `t` (puede transferir quien recibe), no `T`. Así nadie externo puede
usar `#1` para saltar a otras extensiones o, más adelante, a llamadas salientes
que se pagan.

Mientras CallMyWay no esté conectado, el menú se prueba marcando **9000** desde
cualquier teléfono interno.

## Por qué la opción 1 tarda unos segundos

`1` es también el primer dígito de `1001` y `1002`. Al presionar `1`, Asterisk no
sabe todavía si la persona va a seguir marcando, así que espera
`TIMEOUT(digit)` = 3 segundos. Si no llega otro dígito, ejecuta la opción 1.

## Grabación de los audios

Los audios del menú se graban desde el teléfono. Después del beep se habla, y se
termina con `#` (o con 4 segundos de silencio). Luego se escucha cómo quedó; si no
gusta, se vuelve a marcar el mismo número.

| Marcar | Archivo | Texto sugerido |
|---|---|---|
| 9001 | `menu.wav` | "Bienvenido a Telsolis. Si conoce la extensión, márquela ahora. Para comunicarse con todos, presione 1. Para el celular, presione 2. Para la computadora, presione 3." |
| 9002 | `opcion-invalida.wav` | "La opción marcada no es válida." |
| 9003 | `despedida.wav` | "No se recibió ninguna opción. Gracias por llamar a Telsolis. Hasta luego." |

Los archivos quedan en `/var/lib/asterisk/sounds/telsolis/` (variable `DIR_AUDIOS`
de `extensions.conf`). **Hay que grabarlos antes de probar el menú**: si
`menu.wav` no existe, `Background()` falla y la llamada se corta.

## Archivos

| Archivo | Cambio |
|---|---|
| `extensions.conf` | Contexto `menu-principal`; subrutinas `sub-llamar-todos` y `sub-grabar-audio`; extensiones 9000-9003; `sub-llamar-extension` acepta las opciones de `Dial` como segundo argumento |

## Instalación

```bash
# 1. Carpeta de los audios del menú
sudo mkdir -p /var/lib/asterisk/sounds/telsolis
sudo chown asterisk:asterisk /var/lib/asterisk/sounds/telsolis

# 2. Configuración
sudo cp ~/extensions.conf /etc/asterisk/
sudo chown asterisk:asterisk /etc/asterisk/extensions.conf
sudo asterisk -rx "dialplan reload"
sudo asterisk -rx "dialplan show menu-principal"
```

**Idioma.** Los audios del menú están grabados en español, pero los mensajes del
sistema (buzón, conferencias, transferencias) quedan en inglés: se decidió no
instalar `asterisk-core-sounds-es` ni cambiar el idioma de los canales. Si se
cambiara el idioma a `es` sin esos sonidos, Asterisk armaría algunas frases con
reglas del español y archivos en inglés, y podrían quedar incompletas.

## Plan de pruebas

Antes: marcar **7001** (horario abierto) y grabar los tres audios (9001-9003).

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | Desde la PC marcar 9000 | Se escucha el menú grabado |
| 2 | 9000 y marcar `2` | Suena el celular; al contestar se hablan |
| 3 | 9000 desde el celular y marcar `3` | Suena la PC |
| 4 | 9000 y marcar `1` | Tras ~3 s suenan la PC y el celular a la vez; al contestar uno, el otro deja de sonar |
| 5 | 9000 y marcar `1002` | Suena el celular directamente |
| 6 | 9000 y marcar `5` | "Opción inválida" y se repite el menú |
| 7 | 9000 y no marcar nada | El menú se repite 3 veces y luego se escucha la despedida |
| 8 | 9000 y marcar `#1` durante la llamada con el celular | Quien llamó no puede transferir (solo puede quien recibe) |
| 9 | Marcar 7002 y luego 9000 → `2` | Va directo al buzón del celular |
| 10 | Marcar 7002 y luego 9000 → `1` | Buzón; el mensaje aparece en los buzones de 1001 y 1002 |

## Problemas típicos

| Síntoma | Causa probable |
|---|---|
| Al marcar 9000 se corta enseguida | No existe `menu.wav`: grabarlo con 9001 |
| `Record` falla al grabar | La carpeta no existe o no es de `asterisk`: repetir el paso 1 de la instalación |
| Las teclas del menú no responden | DTMF: revisar `dtmf_mode=rfc4733` y que Linphone use RFC 2833/4733 |
| La opción 1 tarda | Es normal: espera 3 s por si se marca 1001 o 1002 |
