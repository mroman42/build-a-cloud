---
title: "Nubes privadas: OwnCloud y AeroFS"
author: Autor
date: Universidad de Granada
abstract: " "
mainfont: Arial
fontsize: 10pt
geometry: "a4paper, top=2.5cm, bottom=2.5cm, left=3cm, right=3cm"
csl: ieee.csl

bibliography: references.bib
---


Una **nube privada** es aquella cuyo control y uso es exclusivo de una
organización concreta, tal y como la define [@clouddef], sin que se almacenen
datos de la organización en servidores externos, como ocurre con las nubes
públicas. En este trabajo se
analizarán dos alternativas de software orientadas a un sistema de compartición
y sincronización de archivos para una nube privada, OwnCloud, una alternativa
libre, y AeroFS, una alternativa propietaria.

Sobre ellas se expondrán los aspectos principales de uso, administración,
seguridad y monitorización y se compararán cualitativamente. Se observará que la
principal diferencia entre ambas tiene que ver con su arquitectura y cómo afecta
esta a la propagación de los cambios.
Finalmente, se expondrán otras soluciones de nube privada.

# OwnCloud

OwnCloud proporciona software de servidor y de cliente para construir una nube
privada (*private cloud* [@clouddef]) orientada al almacenamiento y a la
compartición de archivos. Owncloud es software libre, permitiendo su copia,
distribución y modificación en los términos de la *Affero General Public
License*, la licencia del proyecto GNU orientada a servicios en web. [@affero]
Nació como parte del proyecto **KDE** para permitir a los usuarios control de
sus archivos y se independizó como *ownCloud Inc.*, ofreciendo soporte
empresarial. [@owncloudhistory]

El núcleo del servidor de ownCloud está escrito en **PHP**, con el
cliente de escritorio escrito en **C++**. Todo el código fuente puede
consultarse directamente desde repositorios públicos. [@owncloudgit]

OwnCloud permite acceder a los datos mediante el protocolo **WebDAV** o mediante
una interfaz web que facilita las búsquedas, la edición y la sincronización de
los archivos. Permite la federación de varias nubes, lo que hace que usuarios de
una nube puedan compartir archivos con los usuarios trabajando en otra
instalación de otra nube distinta federada. Además, permite la extensión de la
plataforma base con aplicaciones externas (*apps*) que puede controlar el
administrador directamente desde la aplicación. [@ownuser]

Podemos distinguir tres formas distintas de usar ownCloud, para una instalación
personal o empresarial:

* **Servidor propio**: podemos instalar y montar nuestro servidor de ownCloud
  sobre un ordenador al que tengamos acceso directo.
* **Servidor contratado**: realizar la instalación sobre un servidor virtual que
  además nos provea de otros componentes como Apache, PHP o la base de datos.
* **Como servicio**: contratar directamente a un proveedor de ownCloud,
  encargado del servicio y del mantenimiento.

En este trabajo exploramos la primera vía, que se destaca por ser la única en la
que tenemos control completo sobre la gestión de los datos que almacenemos en la
nube, consistiendo estrictamente en una nube privada. Tendremos por tanto que
usar una máquina como servidor propio, sobre el que empezaremos instalando un
servidor web y un servidor de bases de datos. Owncloud nos ofrece el software
del lado del servidor en tres ediciones distintas:

* **Community-supported**: versión básica y gratuita. No se ofrece soporte
  oficial para esta versión más que el que pueda obtenerse de la comunidad de
  ownCloud. No consta de otras diferencias fundamentales con las versiones con
  soporte.
* **Standard Subscription**: versión que contrata el soporte de la *ownCloud
  Inc.* para el núcleo del servidor sin las aplicaciones.
* **Enterprise Subscription**: versión que añade aplicaciones empresariales, así
  como soporte, al servidor de *ownCloud*.

En nuestro caso analizaremos la versión de la comunidad en su **versión 8.0.2**
[@ownadmin], y la haremos funcionar sobre un sistema *GNU/Linux*.  Construiremos
nuestra nube con ownCloud sobre una máquina virtual usando **Virtual Box** como
software de virtualización y usaremos **Ubuntu Server 14.04** para 64 bits como
sistema operativo. La máquina virtual la crearemos con 1024MB de memoria RAM y
8GB de espacio en disco.



## OwnCloud como usuario

La propia página de ownCloud ofrece paquetes para la mayoría de distribuciones
Linux en el **openSUSE Build Service**, que mantiene los repositorios de las
distintas versiones. [@opensusebuild] La instalación en sistemas derivados de
Debian puede realizarse añadiendo el repositorio:

``` bash
http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_14.10/
```

E instalando desde un gestor de paquetes los paquetes `owncloud-client`, que
proporciona la interfaz gráfica para el cliente de escritorio, y `owncloud`,
alternativamente `owncloud-server`, que proporciona el software del servidor
privado:

```bash
sudo apt-get update
sudo apt-get install owncloud-client
```

La documentación de ambos puede encontrarse en los paquetes
`owncloud-client-doc` y `owncloud-doc` respectivamente.

### Cliente de escritorio

*OwnCloud* ofrece clientes de escritorio para **Linux**, **OS X** y **Windows**
además de para plataformas móviles como **Android**. La instalación del cliente
de escritorio en sistemas *GNU/Linux* puede realizarse desde el mismo
repositorio de **OpenSUSE build** referenciado anteriormente.

El cliente exige al inicio una dirección de servidor a la que conectarse. En
nuestro caso, en el que hemos construido el servidor sobre la misma máquina que
hará el papel del cliente, será `localhost/owncloud`. En general, seguirá este
mismo formato `<servidor>/owncloud`; ya que la instalación por defecto ubicará el
servidor en el directorio `/var/www/owncloud`.

## Owncloud como administrador

Como administradores, podemos seguir el manual de administración de ownCloud. [@ownadmin]

Para configurar los permisos sobre ownCloud, el usuario de HTTP del sistema debe
tener control sobre el directorio de ownCloud (`/var/www/owncloud`). Este
usuario es el que posea el proceso `php/httpd` que se está ejecutando
actualmente en el sistema. Variará según la distribución que se esté usando. Por
ejemplo, en Ubuntu el usuario de
HTTP es `www-data`. Para averiguarlo en una distribución cualquiera, puede
ejecutarse el siguiente script en PHP [@phpexec]:

```php
<?php echo exec('whoami'); ?>
```

La mayoría de operaciones de administración pueden realizarse a través de una
interfaz de línea de comandos escrita como un script de PHP situado en la
carpeta `var/www/owncloud/`. Puede invocarse con el comando `occ`, pero necesita
ser activado por el usuario `www-data`, por lo que lo usaremos con `sudo -u
www-data php occ`.

Este script nos permite varias funciones básicas de mantenimiento, útiles ambas
en el caso de querer suspender el acceso de los usuarios al sistema temporalmente:

* Un **modo de mantenimiento** (*manteinance mode*), que bloquea las acciones de
  otros usuarios, o permite sólo a los administradores logearse mientras está
  activado.
* Un **modo de usuario único** (*single-user mode*), que sólo permite el acceso
  del administrador al sistema.

Las opciones de administración quedan también disponibles en el fichero
`owncloud/config/config.php`. Allí pueden cambiarse todos los parámetros
relativos a la sincronización con las bases de datos, seguridad, aplicaciones y
mantenimiento. [@ownadmin]

### Gestión de usuarios

Los privilegios del usuario serán controlados por el administrador y
establecidos para cada uno de los usuarios independientemente. Owncloud soporta
el uso de grupos de usuarios, cuotas de disco y el nombramiento de varios
subadministradores entre los usuarios. La gestión se puede realizar por medio de
`occ user`, que permite las opciones:

* `user:lastseen`, `user:report`, para monitorizar los usuarios del sistema.
* `user:resetpassword`, `user:delete`, para borrar la contraseña o el usuario.

La autenticación de los usuarios se hace mediante el uso del **protocolo LDAP**
(*Lightweight Directory Access Protocol*). En este protocolo, el cliente realiza
peticiones contra el servidor, suponiendo cada una de ellas una acción atómica
del servidor sobre el directorio, que lo deja en un estado coherente.
En general, los servidores se ven obligados por el protocolo a devolver un
mensaje indicando que la acción requerida se ha completado, pero esta emisión de
mensajes no tiene por qué ser síncrona. Además, cuando se
cierra la conexión a un nivel más bajo de la capa de mensajes de LDAP, el
cliente no puede tener certeza de que las operaciones requeridas se hayan
llevado a cabo. Nótese que estas limitaciones del protocolo no suponen problema
para la autenticación de usuarios, que consiste en el uso que le da ownCloud.

Para mantener una coordinación sobre las instrucciones del protocolo, cada una
de ellas lleva un identificador de mensaje `MessageID`, que debe ser distinto
para cada una de las peticiones. El comportamiento sería indeterminado si un
cliente realizara varias peticiones bajo un mismo identificador. [@rfcLDAP]

También se permite realizar la autenticación por el **protocolo WebDAV** como una
opción configurable. Este consiste en una extensión al protocolo *HTTP/1.1* para
permitir operaciones que respeten la autoría del contenido e implementar ciertas
abstracciones que facilitan la gestión de recursos. [@rfcWebDAV2]


### Gestión de extensiones

Las `apps` o extensiones de ownCloud que se están ejecutando en cada momento en
la nube son gestionadas por el admnistrador desde el comando `occ app`, que
permite las opciones:

* `app:enable`, `app:disable`, para habilitar o deshabilitar una extensión.
* `app:list`, para listar las extensiones disponibles.

Por ejemplo, para activar la autenticación de usuarios por `WebDAV`, vamos a
usar el comando `occ app:enable user_webdavauth`. [@ownadmin]


### Base de datos y LAMP

En la nube que estamos creando instalamos previamente un servidor **LAMP**
(Linux, Apache, MySQL, PHP) con
una base de datos **MariaDB** que será la que usemos desde ownCloud para iniciar
el servicio. Esta instalación es requisito para el funcionamiento de ownCloud,
que requiere de un servidor web para permitir el acceso a él.

Owncloud usa por defecto **SQLite**, pero esta es una base de datos sólo
recomendada para pruebas y no para entornos de producción. La elección de una
base de datos entre las instaladas puede realizarse al instalar ownCloud en la
pantalla de acceso inicial (imagen \ref{own1}).

![Pantalla inicial de administración de OwnCloud \label{own1}](own1.png)

Para pasar a usar nuestro SGBD, necesitaremos crear un usuario que
pueda pasar a usar `ownCloud` y una base de datos dentro del sistema.
En nuestro caso, dentro del sistema de MySQL daremos permisos al usuario
`owncloud` sobre una base de datos que llamaremos `owncloud`. [@ownadmin]


### Control de versiones y sincronización

Owncloud consta de un sistema de control de versiones simple que guarda copias
de seguridad y varias versiones históricas y las elimina según avanza el tiempo.
No facilita el cambio de este sistema por cualquier otro.

La sincronización en ownCloud se realiza mediante `csync`, una utilidad de
sincronización con licencia `GNU LGLP` que utiliza internamente el protocolo
`sftp`. Recientemente añadió un módulo específico para dar soporte a
ownCloud, sirviendo como sincronización entre un cliente de ownCloud y el
servidor central.



La característica principal de este sistema de sincronización es que es
bidireccional. Los cambios se propagan temporalmente ordenados de un lado a otro
y se comprueban a la vez a ambos lados de la sincronización. Nótese la
diferencia con utilidades como `rsync`, que sirven para la sincronización
unidireccional y que se desaconsejan para casos como este. [@csync]

### Seguridad

Parte de la motivación para gestionar una nube propia es la seguridad de los
datos. Evitar que estos se almacenen en servidores externos y públicos más
fácilmente expuestos a ataques de seguridad.

La configuración de seguridad básica propuesta a través de la documentación de
ownCloud [@ownadmin] consiste en activar el acceso de lectura para el usuario de
PHP a `/dev/urandom` para permitirle extraer números pseudoaleatorios
criptográficamente seguros, cambiar el directorio de ownCloud fuera de la raíz
web `/var/www`, configurar `https` en el servidor web y forzar el uso de `ssl`
en el propio ownCloud.

### Aplicaciones

OwnCloud basa su gran parte de su funcionalidad en ofrecer una serie de
aplicaciones, tanto
propias de la aplicación como escritas por terceras partes. El servicio para
reunir esa oferta de aplicaciones es ownCloud Apps Store. [@owncloudapps]


## Monitorización y control de actividad

Una opción para monitorizar nuestra nube es usar las propias herramientas que
ofrece ownCloud. Estas nos proporcionan datos generales de uso del servidor y
del almacenamiento, pero no son capaces de obtener datos en más
profundidad. Ejemplos de estas aplicaciones pueden encontrarse en la ownCloud
Apps Store, como `Storage Usage` o `SuperLog`.

Para comprobar simplemente que el servidor sigue funcionando, puede consultarse
el archivo `/owncloud/status.php`. Para obtener una traza detallada, puede
recurrirse al archivo `/owncloud/owncloud.log`. El nivel de detalle de estos
registros puede ajustarse según nuestras necesidades en el archivo
`config/config.php`, indicando la sentencia PHP siguiente:

```php
define('DEBUG',true);
```

Además, deben monitorizarse por separado los distintos componentes que forman la
estructura de ownCloud, como el servidor o la base de datos. Puesto que estos
funcionan de manera independiente a la nube, la monitorización de los mismos se
realizará con las herramientas que provean.

### Optimización de rendimiento

En la documentación de ownCloud [@ownadmin] se tratan varias posibles mejoras de
rendimiento, que se exponen aquí. Los factores más determinantes en el
rendimiento, en cualquier caso, son los debidos a los servidores (web y de base
de datos) sobre los que se basa ownCloud.

En cuanto al servidor web, habrá que regular el número de procesos máximos
activos para evitar que la memoria que consume cada uno de ellos (en torno a los
12MB) sobrepase la cantidad de memoria RAM.
Se recomienda activar el protocolo `SPDY`, porque suele incrementar la
eficiencia; y desactivar el modo seguro de PHP, que se considera obsoleto.

En cuanto a la base de datos, ya se desaconsejó el uso de SQLite, y las opciones
MySQL y MariaDB constan ambas de herramientas específicas para su ajuste de
rendimiento, como *MySQLTuner*. Se recomienda además la creación de varios
índices sobre las tablas `oc_*` que usa ownCloud para gestionar usuarios y
archivos. Estos índices se detallan en la documentación [@ownadmin] y pasarán a
formar parte del código cuando se compruebe que producen una mejora
significativa del rendimiento [@owngitindex].

# AeroFS

AeroFS es una herramienta propietaria que permite la sincronización y
compartición de archivos para construir sobre ella una nube privada. Todo ello
administrado de manera centralizada y bajo el firewall privado. [@aerofs]

La compañía AeroFS permite también instalar un modelo de nube híbrida que se
conecta a los servidores de AeroFS para ciertas tareas como la creación de
cuentas de usuario y el envío de correos de notificación, útiles en la recogida
de registros de funcionamiento del sistema. Esta opción no entra en el ámbito de
lo que se expone aquí por no considerarla propiamente una *nube privada*.

## Características

AeroFS usa la *AeroFS's Smart Routing Technology*
para sincronizar los datos dentro de la propia red interna, con la que el
fabricante afirma que mejora entre 10 y 100 veces la velocidad de otras
alternativas como *Dropbox*. [@aeroover] Aunque no se
proporcionan más detalles de la tecnología, podemos deducir de lo que el propio
fabricante afirma que se trata de permitir el enrutamiento directo de los
archivos compartidos por la intranet sin pasar por un servidor centralizado. Sin
embargo, no se nos ofrece información para contrastarlo:

*"Nuestra tecnología Smart Routing mantiene los datos dentro de la LAN
local, beneficiándose del hecho de que la mayoría de routers de punto final y
conmutadores son mucho más rápidos que los enlaces de telecomunicaciones de Internet"*
(AeroFS Overview, traducción de [@aeroover])

La administración de todo el sistema está centralizada en el servidor ofreciendo
la aplicación y puede realizarse desde un navegador web. Todos los logs y la
información de auditoría pueden accederse desde una interfaz JSON
comprensible para herramientas de monitorización.

La autenticación puede realizarse por los protocolos **LDAP**, **AD** y
**OpenID**. El cifrado de los datos se realiza extremo a extremo, usando el
estándar **AES-256** o el algoritmo **2048-bit RSA**.

El registro en la página de AeroFS nos permite acceder a una versión de prueba
limitada a 30 usuarios y a 10 años de uso. Para este trabajo usaremos la versión
de prueba de **AeroFS 1.0.7** descargada como imagen de máquina virtual *.ova*
para instalarla sobre **Virtual Box**. La página de registro nos ofrece también
versiones **QCow2** para ser instaladas sobre plataformas como **Open Stack**.
Esta máquina virtual sobre la que se ofrece AeroFS tiene como sistema operativo
*Ubuntu 12.02 (64 bits)*.


## Instalación

Al iniciar la máquina virtual, esta empieza ejecutando un script de inicio que
genera las claves públicas y pirvadas que usará AeroFS e inicia los distintos
servidores que necesita (como el servicio de log). Después se pasa directamente
a una pantalla de inicio para configurar la red sobre la máquina, ofreciendo
*DHCP* y una *IP estática* como opciones. Al terminar la configuración de red,
la interfaz queda disponible sobre una dirección IP mostrada por la consola de
comandos de AeroFS (imagen \ref{aerofs}).

![Interfaz de comandos de AeroFS \label{aerofs}](aerofs.png)

Seguidamente nos pedirá incluir la licencia del producto, elegir un nombre de
dominio y asegurarnos de que los puertos TCP que usará la aplicación no se
encuentran bloqueados por ningún software cortafuegos (*firewall*) o por estar
dentro una red privada virtual (*VPN*). AeroFS usa los puertos:

```
 80, 443, 3478, 4433, 5222, 8084, 8484, 8888, 29438
```

A partir de ahí, simplemente se realizan comprobaciones de la licencia de AeroFS
y se permite incluir un certificado SSL. En particular pedirá un correo
electrónico que se usará para notificaciones al administrador.

### Gestión de usuarios

Al terminar la instalación, se facilita la creación de un primer usuario
administrador, que tendrá permisos de gestión del sistema y del resto de
usuarios.

A partir de aquí, el resto de usuarios pueden ser añadidos. La única
comprobación que se hace sobre ellos es un correo de confirmación. Sin embargo,
si AeroFS ha sido ya integrado con **LDAP** u otro sistema de gestión de
usuarios, podrá accederse directamente desde la interfaz web.

Cada uno de los usuarios que acceda podrá instalar su propio cliente de
escritorio. Esto puede traer problemas para centralizar reportes de fallos en un
cliente concreto. AeroFS permite ordenar a los clientes que envíen estos
reportes de error (*logs*) al servidor central, pero el cumplimiento de esta
orden se ve condicionado a que la cuenta de los clientes se encuentre activa o
se haga uso de ella en un plazo inferior a siete días. En la documentación de
AeroFS no se decribe otra manera de realizar esta recolección de
reportes. Por otro lado, se permite que un usuario reporte un problema
directamente, que notificará al correo del administrador enviándole en ese
momento el reporte de error. [@aerofslogs]

### Configuración del certificado SSL

AeroFS usa el protocolo **SSL** para garantizar la
seguridad de las comunicaciones de los clientes con el servidor y entre
ellos. Es un protocolo que usa criptografía simétrica en una primera fase y
criptografía asimétrica (de clave pública) en una segunda fase. En la fase
asimétrica, se usan certificados que contienen las claves pública y privada.

El certificado SSL que usa AeroFS por defecto es autofirmado. Este es un
certificado que no está validado por ninguna autoridad certificadora (CA), y al
aceptarlo la primera vez, se acepta implícitamente que la identidad del
expendedor
del certificado es de confianza. [@sslcrl] Esto causará que la mayoría de
navegadores web emitan un mensaje de alerta al acceder a la interfaz web de
AeroFS.

Cuando se posee un certificado reconocido por alguna autoridad
certificadora de confianza en formato PEM, puede usarse como certificado para el
servidor indicándolo en la sección de seguridad del apartado *Setup*, que pedirá
que indiquemos el certificado que pasará a usar a partir de ahora.

Una vez configurada, cada vez que el cliente se conecta verifica la corrección
del certificado. Entonces proporciona el nombre de usuario y una petición de
firma del certificado al servidor, junto con la contraseña codificada. El
servidor firmará el certificado y lo devolverá al cliente. De esta forma, se
crea un nuevo certificado que permite al servidor controlar la identidad del
cliente y que será usado en toda la comunicación posterior para verificar que
esa identidad sea correcta.

# Comparación

Owncloud y AeroFS son dos opciones de software de nube privada, cubriendo unas
necesidades similares. Ambas pueden ser desplegadas sobre un sistema operativo
en la nube como **OpenStack**. Tiene sentido por tanto establecer una
comparación en términos cualitativos entre ambas.

Hay varios puntos en los que ambas opciones dependen de protocolos externos
independientes y por tanto se comportan de manera similar. La autenticación de
usuarios puede realizarse en ambos casos
mediante **LDAP**; la seguridad de las comunicaciones se garantiza a través de
**SSH**, usando la implementación *OpenSSH* en ambos casos. Una variación entre
ambos es que mientras que ownCloud permitía la integración con bases distintas
de la que traía por defecto (*SQLite*), como se explicó anteriormente, AeroFS
sólo se integra con bases de datos externas para la replicación de los datos y
la realización de copias de seguridad. Internamente, podemos suponer que AeroFS
utiliza una versión de **SQLite** por las publicaciones del equipo de
desarrollo [@aeroamazon], pero no hay ninguna confirmación en versiones posteriores.


## Arquitectura

En cuanto a la arquitectura con la que ambos comparten los archivos, podemos
notar una diferencia crucial. En el caso de ownCloud, el sistema consta de un
servidor central, encargado de sincronizar todos los archivos y al que se
conectarán todos los clientes. La implementación de un sistema que
permitiera la sincronización directa entre clientes no está disponible pero está
siendo estudiada por la comunidad en el repositorio del proyecto (*Issue #230* [@owncloudgit]).
Una implementación de este tipo dependería sólo del servidor para comprobar la
disponibilidad en otros clientes y
la integridad del archivo. Sin embargo, plantea varios problemas con la
estructura que ha seguido el desarrollo hasta ahora. El problema principal que
dificulta esta implementación
tiene que ver con la imposibilidad de `csync` de soportar un sistema dependiente de un
servidor central, ya que se concibió para esas tareas como una herramienta
enfocada a los casos en los que no se quería
depender de un servidor central. [@csync]

Mientras tanto, la arquitectura de AeroFS permite el intercambio de archivos
directamente entre clientes. La implementación exacta de este mecanismo forma
parte de la tecnología *Smart Routing* comentada anteriormente y no detallada
por el equipo de desarrollo. Sabemos por la documentación de AeroFS [@aerofsts] que también
posee un servidor central, el *Team
Server*; pero este sólo tiene como funciones el recopilar todos los distintos
cambios que se hagan a los archivos en los clientes, el servir de puente para
sincronizar archivos entre dos clientes que no tienen por qué estar encendidos
al mismo tiempo y servir para propósitos de auditoría, seguridad y recuperación
de datos. No obliga a los clientes a enviar y obtener todos los cambios
directamente a él, simplemente a comunicarlos para mantener consistencia.

## Aplicaciones

Al contrario que ownCloud, no se ofrece la posibilidad de extender la
funcionalidad del servidor de AeroFS con aplicaciones. Esto no afecta a la
funcionalidad básica que ambos ofrecen, que consiste en la compartición y
sincronización de archivos. Pero sí permite utilizar ciertas herramientas
directamente en la nube, como editores o visualizadores de archivos, que reducen
la necesidad de instalaciones redundantes de software de este tipo en cada uno
de los equipos clientes de la nube.

Además, de esta manera se permite al administrador de la nube escribir
aplicaciones propias como extensiones al sistema. El sistema de AeroFS se ve
limitado por carecer de un sistema similar para su extensión.

## Otras alternativas

Existen otras soluciones de nube privada que no se han tenido en cuenta en este
desarrollo. A continuación se exponen algunas de ellas:

* **FileCloud**: Es una alternativa de software privativo que permite la
  compartición y sincronización de archivos, orientada al ámbito
  empresarial. Permite el acceso mediante WebDAV y la integración con
  LDAP, y usa *AES-256 SSL* para una encriptación asimétrica. Funciona de manera
  similar a ownCloud, permitiendo igualmente la
  extensión con aplicaciones, como visores y editores de documentos. La
  compartición también se realiza centrada en el servidor. [@filecloud]
* **Sparkle Share**: Licenciado bajo la `GPLv3`.
  Usa internamente **git** como
  sistema de control de versiones y *AES 256* para la encriptación en el lado
  del cliente. [@sparklegit] **Git** fue diseñado por Linus Torvalds
  intentando que fuera liviano y local y ayuda principalmente a
  sincronizar y mezclar los cambios en archivos editados por distintos
  usuarios. [@git] [@linusgit] Debido al uso de este sistema de control de
  versiones, el uso de *Sparkle Share* se recomienda sólo para archivos de texto
  no demasiado grandes, donde los cambios que se realicen puedan ser trazados
  fácilmente por git. Está especialmente desaconsejado su uso para copias de
  seguridad de sistemas de gran tamaño. [@sparkle]
* **BitTorrent Sync**: Es un software propietario que se basa en el protocolo
  `P2P`. Su arquitectura es más parecida a la de AeroFS, realizando la
  sincronización de archivos directamente entre dispositivos y sin un servidor
  central. Usa actualizaciones incrementales de los archivos para controlar las
  versiones y encriptación de las comunicaciones. [@bittorrent]
* **SeaFile**: Licenciado bajo la `GPLv3`. [@gitseafile] Permite la
  sincronización separada de
  archivos dividiéndolos en grupos llamados *librerías*. La sincronización se
  realiza contra un servidor central mediante *HTTPS*. Una interfaz web para
  accederlo puede servirse desde un servidor *HTTP* como Apache mediante una
  utilidad llamada **Seahub**. Permite la integración tanto con SQLite como
  con cualquier servidor de bases de datos MySQL. [@seafile]

## Conclusiones y comparación con nubes públicas

Debido a las distintas características respecto a arquitectura, Owncloud y
AeroFS pueden servir a propósitos distintos. En una nube privada centralizada
para un equipo pequeño, el tener un servidor central que permita realizar las
auditorías y las copias de seguridad fácilmente, como ofrece Owncloud, puede ser
preferible. La limitación estará en el tamaño máximo que pueda soportar el
servidor. En una nube privada donde haya que compartir grandes archivos, será
usualmente más eficiente el permitir la sincronización directa entre clientes,
como permite AeroFS.

Las diferencias en cuanto a sistemas de seguridad y autenticación son
menores. En cuanto a capacidad, ambas dependen de la del servidor central, por
lo que no se planteará una diferencia significativa al usar una u otra. La
velocidad es teóricamente superior en el caso de AeroFS al permitir la
sincronización entre clientes, pero no se ha llevado a cabo ningún estudio
empírico probándolo. Los sistemas de control de versiones de ambos vienen ya
integrados en el software de cliente y servidor y son dependientes del servidor
central.

Por otro lado, es pertinente una comparación con los sistemas de nube pública,
como **Dropbox**. En cuanto a las posibilidades para el usuario final, ambas
soluciones son similares, permitiendo acceso a través de servidores web,
encriptación de los archivos y autenticación mediante certificados, como se
expone en [@dropbox]. Las principales diferencias provienen de la arquitectura
en el hecho de que todas las sincronizaciones en una nube pública deben
realizarse contra un servidor externo, normalmente mucho más lento en su acceso
que cualquier servidor local en el que podamos decidir construir nuestro
servidor para una nube privada. La limitación que ofrecen los sistemas de nube
privada viene dada por las limitaciones del servidor que los aloja, que no
presenta tanta flexibilidad para almacenamiento, ni tanta capacidad para la
escalabilidad como un almacenamiento externo y que pueda contratarse según la
demanda. En cuanto a la seguridad, ambos implementan sistemas fiables de
protección de los datos, pero en casos de información sensible, donde se quiere
evitar a toda costa una posible filtración de los datos, se recomiendan sistemas
de nube privada que eviten que los datos sensibles deban salir de la red local
de la organización que los controla.


# Bibliografía
