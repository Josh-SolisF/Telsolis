# Proyecto 2: Central Telefónica

**Instituto Tecnológico de Costa Rica** · Escuela de Computación
**Curso:** Redes de Computadoras (IC-7602) · II Semestre 2026
**Profesor:** Kevin Moraga
**Estudiantes:**

- Joshua Solís Fuentes (2023064637)
- Jesús Solís (2023143963)

---

## Tabla de contenidos

1. [Introducción](#1-introducción)
2. [Ambiente de desarrollo](#2-ambiente-de-desarrollo)
3. [Diseño](#3-diseño)
4. [Instalación y configuración](#4-instalación-y-configuración)
5. [Actividades realizadas por estudiante](#5-actividades-realizadas-por-estudiante)
6. [Autoevaluación](#6-autoevaluación)
7. [Lecciones aprendidas](#7-lecciones-aprendidas)
8. [Bibliografía](#8-bibliografía)
9. [Documentación de los archivos de configuración](#9-documentación-de-los-archivos-de-configuración)

---

## 1. Introducción

El problema a resolver en este proyecto es construir una central telefónica, a
la cual llamamos **Telsolis**, usando software y una máquina virtual, sin
equipo telefónico especializado. La central debe comunicar teléfonos internos
entre sí, pero también conectarse con la red telefónica pública, de forma
que cualquier persona pueda llamar desde su celular a un número real y que los
teléfonos de la empresa puedan llamar hacia afuera.

Para resolverlo instalamos Asterisk en una máquina virtual con Ubuntu
Server. La central tiene dos extensiones: la computadora (1001) y el celular
(1002), ambas con el softphone Linphone. Sobre ellas implementamos lo que pide
el enunciado:

- un **horario de atención**: dentro del horario las llamadas suenan y fuera de
  él van al buzón de voz;
- un **cuarto de conferencias**;
- **transferencia** de llamadas entre extensiones;
- un **menú de voz** para quien llama al número público, que permite marcar la
  extensión directamente o presionar 1 (todos los teléfonos), 2 (celular) o
  3 (computadora);
- **llamadas entrantes y salientes** con la red pública.

El enunciado propone CallMyWay como proveedor de la línea telefónica. Al
investigar, vimos que este y la mayoría de proveedores están orientados a
empresas y cobran un monto inicial. Por eso contactamos a Ring.cr, un
proveedor que nos ofreció un plan para estudiantes. Con él obtuvimos una
troncal SIP y el número **+506 4600-8422**, que es el número al que se llama
para escuchar el menú de la central.

## 2. Ambiente de desarrollo

| Componente | Herramienta | Uso |
|---|---|---|
| Equipo anfitrión | Laptop con Windows | Ejecuta la máquina virtual y el softphone de la computadora |
| Virtualización | Oracle VirtualBox | Máquina virtual `telsolis`, red en modo puente (192.168.40.170) |
| Sistema operativo | Ubuntu Server 26.04.1 LTS | Sistema de la máquina virtual |
| PBX | Asterisk 22.5.2 | Central telefónica, con el canal SIP `chan_pjsip` |
| Sincronización de hora | chrony | Mantiene la hora correcta, necesaria para el horario de atención |
| Softphones | Linphone para Windows e iOS | Extensiones 1001 (computadora) y 1002 (celular) |
| Proveedor SIP | Ring.cr (portal sip.cr) | Troncal SIP y número público +506 4600-8422 |
| Acceso remoto | OpenSSH (`ssh`, `scp`) | Administración de la VM y copia de los archivos de configuración |
| Control de versiones | Git y GitHub (repositorio `Telsolis`) | Historial de la configuración y de la documentación |
| Documentación | Markdown | Esta documentación |

El proyecto no requirió scripts propios en C o Python: toda la funcionalidad se
implementó con la configuración de Asterisk y su plan de marcado.

## 3. Diseño

### 3.1 Red

La máquina virtual está en **modo puente**, por lo que tiene su propia
dirección en la red local (192.168.40.170). Los softphones se registran en
Asterisk por SIP y el audio viaja por RTP, siempre pasando por Asterisk.

Para la conexión con la red pública, Asterisk se **registra** en el servidor de
Ring.cr como si fuera un teléfono, y por esa misma conexión recibe las llamadas
entrantes. Así la central funciona detrás del router de la casa sin necesitar
una IP pública fija.

### 3.2 Plan de numeración

| Número | Función |
|---|---|
| 1001 | Extensión de la computadora |
| 1002 | Extensión del celular |
| 600 / 601 | Prueba de eco / prueba de audio |
| 7000 / 7001 / 7002 | Horario automático / forzar abierto / forzar cerrado |
| 8000 | Cuarto de conferencias |
| 8500 | Buzón de voz |
| 9000 | Llamada externa simulada (entra al menú) |
| 9001 a 9003 | Grabación de los audios del menú |
| 8 dígitos que empiezan del 2 al 8 | Llamadas salientes a Costa Rica |
| +506 4600-8422 | Número público: llamadas entrantes al menú |

### 3.3 Plan de marcado (dialplan)

El plan de marcado (`extensions.conf`) se organiza en **contextos**. Cada
llamada solo puede usar las reglas del contexto en el que entra, lo que separa
lo que pueden hacer los teléfonos internos de lo que puede hacer alguien que
llama desde afuera.

| Contexto | Quién entra | Qué puede hacer |
|---|---|---|
| `internos` | Extensiones 1001 y 1002 | Todos los números del plan de numeración, incluidas las llamadas salientes |
| `desde-ringcr` | Llamadas que entran por la troncal | Solo pasar al menú |
| `menu-principal` | Llamadas externas (y el 9000) | Elegir una opción del menú o marcar 1001 o 1002 |

La lógica que se repite (revisar el horario, llamar a una extensión, mandar al
buzón, llamar hacia afuera) está en **subrutinas** (`sub-*`), que se invocan con
`Gosub`. Así el menú y las llamadas internas usan exactamente las mismas reglas.

### 3.4 Menú

Las llamadas que entran por la troncal pasan al contexto `menu-principal`, que
reproduce el audio grabado y espera una tecla:

| Tecla | Acción |
|---|---|
| 1 | Suenan todos los teléfonos al mismo tiempo |
| 2 | Llama al celular (1002) |
| 3 | Llama a la computadora (1001) |
| 1001 / 1002 | Llama directamente a esa extensión |
| Otra tecla o ninguna | Repite el menú hasta tres veces y luego se despide |

La extensión interna 9000 entra al mismo menú, lo que permitió desarrollarlo y
probarlo sin depender de la troncal.

### 3.5 Horario de atención y buzón de voz

El horario de atención es de lunes a viernes, de 08:00 a 17:00. Si una llamada
llega fuera de horario, o si nadie contesta en 20 segundos, va al buzón de voz
de la extensión. Cada extensión escucha sus mensajes marcando 8500.

Para poder demostrar los dos casos sin depender de la hora, el horario se puede
forzar a "abierto" (7001) o "cerrado" (7002), o dejar en automático (7000). El
modo se guarda en la base de datos interna de Asterisk, por lo que se mantiene
aunque Asterisk se reinicie.

### 3.6 Cuarto de conferencias

La extensión 8000 usa `ConfBridge`. La sala admite hasta 10 participantes,
anuncia cuántas personas hay y pone música de espera mientras hay una sola.
Dentro de la sala, `*1` silencia el micrófono, `*2` dice cuántos participantes
hay y `*3` sale de la sala.

### 3.7 Transferencias

| Tipo | Teclas | Comportamiento |
|---|---|---|
| Directa (ciega) | `#1` + extensión | La llamada pasa de inmediato a la otra extensión |
| Con aviso (consultada) | `*2` + extensión | Quien transfiere habla primero con el destino; quien espera escucha música |

Las teclas se definen en `features.conf`. Quien llama desde afuera no puede
transferir; solo las extensiones internas.

### 3.8 Troncal y llamadas salientes

La troncal `ringcr` se define en `pjsip.conf`. Asterisk se registra en el
servidor del proveedor (148.227.162.40) y reconoce como externas las llamadas
que llegan desde esa dirección.

Para llamar hacia afuera se marca un número de 8 dígitos que empiece del 2 al 8
(fijos y celulares de Costa Rica). Asterisk le agrega el prefijo +506, lo envía
por la troncal y muestra el número público como identificador de llamada.

### 3.9 Decisiones de diseño

| Decisión | Justificación |
|---|---|
| PJSIP en lugar de `chan_sip` | `chan_sip` fue eliminado de Asterisk a partir de la versión 21 |
| Códecs G.711 (`ulaw`, `alaw`) | Los soportan todos los softphones y el proveedor |
| Todo el audio pasa por Asterisk | Necesario para detectar las teclas de transferencia, grabar, mezclar conferencias y atravesar el NAT |
| Subrutinas para llamar | El menú y las llamadas internas comparten la misma lógica de horario y buzón |
| Troncal por registro | Funciona detrás del router, sin IP pública fija |
| Ring.cr en lugar de CallMyWay | Plan para estudiantes sin costo para el proyecto |
| Contraseñas fuera del repositorio | Evitar publicar credenciales en GitHub |

## 4. Instalación y configuración

**Máquina virtual.** La central corre en una máquina virtual de VirtualBox con
Ubuntu Server 26.04. El adaptador de red está en modo puente, para que la VM
tenga su propia dirección en la red local, igual que cualquier otro
dispositivo. La zona horaria está en America/Costa_Rica y la hora se sincroniza
con chrony, porque el horario de atención depende de ella.

**Asterisk.** Se instaló Asterisk 22.5.2 desde los repositorios de Ubuntu
(`apt install asterisk`) y se habilitó para arrancar con el sistema. Los
módulos principales que usa la central son:

| Módulo | Función |
|---|---|
| `chan_pjsip` | Extensiones y troncal SIP |
| `app_voicemail` | Buzón de voz (se desactivó la variante `app_voicemail_odbc`, que entraba en conflicto) |
| `app_confbridge` | Cuarto de conferencias |
| `features` | Teclas de transferencia |

**Configuración.** Los archivos de configuración se mantienen en el repositorio
(`asterisk/config/`) y se copian a `/etc/asterisk/` en la VM. Las contraseñas de
las extensiones, de la troncal y los PIN de los buzones están en archivos
aparte que solo existen en la VM.

**Softphones.** En la computadora y en el celular se instaló Linphone con una
cuenta SIP: usuario 1001 o 1002, su contraseña, la IP de la VM como dominio y
transporte UDP. En el celular (iOS) se desactivó el cifrado del audio.

**Troncal.** Con el plan para estudiantes de Ring.cr se creó una troncal en su
portal, con soporte para NAT, y se le asignó el número +506 4600-8422. La
central se registra en el servidor del proveedor, 148.227.162.40.

**Audios del menú.** Se grabaron con voz propia desde un teléfono, marcando 9001
(menú), 9002 (opción inválida) y 9003 (despedida).

## 5. Actividades realizadas por estudiante

### Joshua Solís Fuentes

| Fecha | Actividad | Horas |
|---|---|---|
| 2026-11-08 | Creación del repositorio y análisis del enunciado | 1.5 |
| 2026-11-10 | Creación de la máquina virtual e instalación de Asterisk | 2.0 |
| 2026-11-13 | Extensiones y configuración de los softphones | 3.0 |
| 2026-11-13 | Horario de atención y buzón de voz | 2.5 |
| 2026-11-19 | Cuarto de conferencias | 1.5 |
| 2026-11-19 | Transferencias | 2.0 |
| 2026-11-20 | Creación del menú | 3.0 |
| 2026-11-21 | Troncal con Ring.cr: llamadas entrantes y salientes | 4.0 |
| 2026-11-22 | Pruebas finales | 2.0 |
| 2026-11-22 | Documentación | 2.5 |
| | **Total** | **24.0** |

### Jesús Solís

| Fecha | Actividad | Horas |
|---|---|---|
| 2026-11-09 | Análisis del enunciado | 0.5 |
| 2026-11-12 | Estudio de voz sobre IP y de Asterisk | 2.5 |
| 2026-11-16 | Investigación de proveedores SIP | 2.0 |
| 2026-11-19 | Pruebas de conferencias y transferencias | 1.0 |
| 2026-11-21 | Revisión de la configuración de la central | 2.0 |
| 2026-11-22 | Pruebas finales | 1.0 |
| 2026-11-22 | Documentación y preparación de la defensa | 2.5 |
| | **Total** | **11.5** |

## 6. Autoevaluación

### 6.1 Estado final

La central quedó completamente funcional. Todas las funciones del enunciado se
probaron con llamadas reales, tanto internas como desde y hacia la red pública:
llamadas entre extensiones, horario con buzón de voz, cuarto de conferencias,
transferencias, menú de voz y llamadas entrantes y salientes.

### 6.2 Problemas encontrados

| Problema | Solución |
|---|---|
| El buzón de voz no funcionaba por un conflicto entre dos módulos | Desactivar el módulo que sobraba |
| La hora de la VM se desfasaba al pausarla, y el horario fallaba | Sincronizar la hora con chrony y apagar la VM en lugar de pausarla |
| La VM a veces tenía archivos de configuración desactualizados | Copiar siempre desde el repositorio |
| La IP del servidor que indicaba el proveedor era privada | El proveedor nos dio la IP pública correcta |
| El número nuevo tardó en activarse para llamadas entrantes | Esperar la activación del proveedor |

### 6.3 Limitaciones

- No se pueden marcar números especiales, como el 911.
- La troncal admite una sola llamada externa a la vez.
- Los avisos del sistema están en inglés.
- En iOS, Linphone debe estar abierto para recibir llamadas.
- Las llamadas externas dependen de la conexión a internet.
- Las llamadas y el audio no están cifrados.

### 6.4 Reporte de commits

| Commit | Fecha | Descripción |
|---|---|---|
| `52ef5a0` | 2026-11-08 | Initial commit |
| `e29a965` | 2026-11-08 | Estructura inicial del proyecto |
| `b66e252` | 2026-11-09 | Initial DNS configuration for docker and preparation for other services *(examen PaaS)* |
| `42704cc` | 2026-11-13 | Asterisk fase 1 y bitácora |
| `6e441e3` | 2026-11-13 | Asterisk fase 2a: buzón de voz y horario de atención |
| `dee43a2` | 2026-11-19 | cuarto de conferencias |
| `ce47e51` | 2026-11-19 | Asterisk transferencias ciega, consultada y por REFER |
| `600b707` | 2026-11-21 | Asterisk voice menu, clearer names and cleaner configs |
| `96d7d60` | 2026-11-22 | Asterisk: troncal Ring.cr con llamadas entrantes y salientes |

### 6.5 Calificación según la rúbrica

| Rubro | Peso | Calificación (0-10) |
|---|---|---|
| Cuarto de conferencias | 20% | 10 |
| Endpoints | 5% | 10 |
| Extensiones | 5% | 10 |
| Rutas Outgoing | 5% | 10 |
| Rutas Ingoing | 5% | 10 |
| Menú | 25% | 10 |
| Transferencias | 10% | 10 |
| Horarios - Voicemail | 25% | 10 |

### 6.6 Autoevaluación

Escala: [1] Muy malo, [2] Malo, [3] Regular, [4] Bueno, [5] Muy bueno.

| Rubro | Joshua Solís | Jesús Solís |
|---|---|---|
| Aprendizaje de Central Telefónica | 5 | 5 |
| Aprendizaje de Voz sobre IP | 5 | 5 |

## 7. Lecciones aprendidas

- **Avancen por fases y prueben cada una antes de seguir.** Así cada error tiene
  pocas causas posibles.
- **Usen la consola de Asterisk (`asterisk -rvvv`).** Muestra paso a paso qué
  hace cada llamada, con ella resolvimos casi todos los problemas.
- **Prueben todo con llamadas internas antes de conectar la troncal.** Así no
  dependen del proveedor ni gastan crédito.
- **Busquen el proveedor temprano** y pregunten por planes para estudiantes como ring.cr (patrocinados) la
  troncal fue lo último en funcionar.

## 8. Bibliografía

1. Asterisk Project. *Asterisk Documentation*. <https://docs.asterisk.org/>
2. Belledonne Communications. *Linphone Documentation*. <https://linphone.org/en/docs/>
3. Ring.cr. *Telefonía IP y troncales SIP*. <https://ring.cr/>
4. Oracle. *VirtualBox User Manual*. <https://www.virtualbox.org/manual/>
5. Rosenberg, J. et al. *RFC 3261: SIP: Session Initiation Protocol*. IETF, 2002. <https://www.rfc-editor.org/rfc/rfc3261>

## 9. Documentación de los archivos de configuración

Los archivos de configuración están en `asterisk/config/` y cada sección tiene
comentarios que explican su función.

| Archivo | Contenido |
|---|---|
| `pjsip.conf` | Extensiones 1001 y 1002, y troncal con Ring.cr |
| `extensions.conf` | Plan de marcado: extensiones, menú, horario y llamadas salientes |
| `voicemail.conf` | Configuración del buzón de voz |
| `confbridge.conf` | Configuración del cuarto de conferencias |
| `features.conf` | Teclas de transferencia |

Las contraseñas y los PIN de los buzones están en archivos aparte que solo
existen en la VM y están excluidos del repositorio.
