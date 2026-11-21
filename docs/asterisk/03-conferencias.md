# Fase 2b: cuarto de conferencias

Rubro: **Cuarto de conferencias (20%)**.

## Comportamiento

Cualquier extensión que marque **8000** entra a la sala `telsolis`. Todos los
participantes de la sala se escuchan entre sí: Asterisk recibe el audio de cada
uno, lo mezcla y le envía a cada participante la mezcla de los demás.

| Situación | Qué pasa |
|---|---|
| Entra la primera persona | Escucha que está sola y luego música de espera |
| Entra alguien más | Se anuncia cuántas personas hay; la música se detiene y se escuchan |
| `*1` | Silencia o reactiva el propio micrófono |
| `*2` | Dice cuántas personas hay en la sala |
| `*3` | Sale de la conferencia |
| Ya hay 10 personas | No se permite entrar a más |

## Archivos

| Archivo | Cambio |
|---|---|
| `confbridge.conf` | Nuevo: perfiles de sala (`perfil-sala`), de participante (`perfil-participante`) y menú (`menu-conferencia`) |
| `extensions.conf` | Extensión 8000 con `ConfBridge()` |

## Instalación

```bash
# Verificar que el módulo de conferencias esté cargado
sudo asterisk -rx "module show like confbridge"      # app_confbridge.so: Running

sudo cp /etc/asterisk/confbridge.conf /etc/asterisk/confbridge.conf.orig
sudo cp ~/confbridge.conf ~/extensions.conf /etc/asterisk/
sudo chown asterisk:asterisk /etc/asterisk/confbridge.conf /etc/asterisk/extensions.conf

sudo asterisk -rx "module reload app_confbridge.so"
sudo asterisk -rx "dialplan reload"
```

## Verificación

```
confbridge show profile bridges      # debe aparecer perfil-sala
confbridge show profile users        # debe aparecer perfil-participante
confbridge show menus                # debe aparecer menu-conferencia
confbridge list                      # salas activas (solo mientras hay alguien dentro)
confbridge list telsolis             # participantes de la sala
```

## Plan de pruebas

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | Desde 1001 marcar 8000 | Anuncio de que está solo y música de espera; `confbridge list` muestra la sala con 1 participante |
| 2 | Con 1001 dentro, desde 1002 marcar 8000 | Anuncio de cuántos hay; la música se detiene y ambos se escuchan |
| 3 | `confbridge list telsolis` en la consola | Aparecen 1001 y 1002 |
| 4 | Desde 1002 presionar `*1` y hablar | 1001 deja de escuchar a 1002; `*1` otra vez lo reactiva |
| 5 | Presionar `*2` | Se escucha la cantidad de participantes |
| 6 | Desde 1002 presionar `*3` | 1002 sale; 1001 queda solo y vuelve la música |
| 7 | Colgar 1001 | `confbridge list` ya no muestra la sala |

## Problemas típicos

| Síntoma | Causa probable |
|---|---|
| `No application 'ConfBridge'` | Módulo no cargado: `module load app_confbridge.so` o reiniciar Asterisk |
| Entra pero no suena música de espera | Faltan los archivos de música: `sudo apt install asterisk-moh-opsound-gsm` |
| Las teclas `*1`, `*2`, `*3` no hacen nada | El teléfono no envía DTMF por RFC 4733; revisar `dtmf_mode` del endpoint y Linphone |
| Se escucha el propio eco | Uno de los participantes usa altavoz sin cancelación de eco; usar audífonos |
