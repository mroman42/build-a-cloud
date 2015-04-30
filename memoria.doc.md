---
title: "Cómo montar una nube"
author: Mario Román García
date: Universidad de Granada
abstract: "Resumen aquí"
mainfont: Arial
fontsize: 10pt
geometry: "a4paper, top=2.5cm, bottom=2.5cm, left=3cm, right=3cm"
csl: ieee.csl

bibliography: references.bib
---

# OwnCloud

OwnCloud proporciona software de servidor y de cliente para construir una
nube privada (*private cloud* [@clouddef]) orientada al almacenamiento y a la compartición de
archivos. Owncloud es software libre, permitiendo su copia, distribución y
modificación en los términos de la  *Affero
General Public License*, la licencia del proyecto GNU orientada a servicios en
web. [@affero]
Nació como parte del proyecto **KDE** para permitir a los
usuarios control de sus archivos y se independizó como *ownCloud Inc.*,
ofreciendo soporte empresarial. [@owncloudhistory]

El núcleo del servidor de ownCloud está escrito en **PHP**, con el
cliente de escritorio escrito en **C++**. Todo el código fuente puede
consultarse directamente desde repositorios públicos. [@owncloudgit]

OwnCloud permite acceder a los datos mediante el protocolo
**WebDAV** o mediante una interfaz web que facilita las búsquedas, la edición y
la sincronización de los archivos. Permite la federación de varias nubes, lo que hace que usuarios de
una nube puedan compartir archivos con los usuarios trabajando en otra
instalación de otra nube distinta federada. Además, permite la extensión de la
plataforma base con aplicaciones externas (*apps*) que puede controlar el
administrador directamente desde la aplicación.

Podemos distinguir tres formas distintas de usar ownCloud, para una instalación
personal o empresarial:

* **Servidor propio**: podemos instalar y montar nuestro servidor de ownCloud
  sobre un ordenador al que tengamos acceso directo.
* **Servidor contratado**: realizar la instalación sobre un servidor virtual que
  además nos provea de otros componentes como Apache o PHP.
* **Como servicio**: contratar directamente a un proveedor de ownCloud,
  encargado del servicio y del mantenimiento.

En este trabajo exploramos la primera vía, que se destaca por ser la única en la
que tenemos control completo sobre la gestión de los datos que almacenemos en la
nube. Instalaremos por tanto un servidor propio. Owncloud nos ofrece el software
del servidor en tres ediciones distintas:

* **Community-supported**: versión básica y gratuita.
* **Standard Subscription**: versión que contrata el soporte de la *ownCloud
  Inc.* para el núcleo del servidor, sin las aplicaciones.
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

E instalando desde un gestor de paquetes:

```bash
sudo apt-get update
sudo apt-get install owncloud
```

### Cliente de escritorio

*OwnCloud* ofrece clientes de escritorio para **Linux**, **OS X** y **Windows**
además de para plataformas móviles como **Android**. La instalación del cliente
de escritorio en sistemas *GNU/Linux* puede realizarse desde el mismo
repositorio de **OpenSUSE build** referenciado anteriormente.

El cliente exige al inicio una dirección de servidor a la que conectarse. En
nuestro caso será `localhost/owncloud`.

## Owncloud como administrador

Como administradores, podemos seguir el manual de administración de ownCloud. [@ownadmin]

Para configurar los permisos sobre ownCloud, el usuario de HTTP del sistema debe
tener control sobre el directorio de ownCloud (`/var/www/owncloud`). Este
usuario varía según la distribución que se esté usando. En Ubuntu, el usuario de
HTTP es `www-data`. Para averiguarlo en una distribución Linux cualquiera, puede
ejecutarse el siguiente script en PHP:

```php
<?php echo exec('whoami'); ?>
```

La mayoría de operaciones de administración pueden realizarse a través de una
interfaz de línea de comandos escrita como un script de PHP situado en la
carpeta `var/www/owncloud/`. Puede invocarse con el comando `occ`, pero necesita
ser activado por el usuario `www-data`, por lo que lo usaremos con `sudo -u
www-data php occ`.

Esto nos permite varias funciones básicas de mantenimiento:

* Un **modo de mantenimiento** (*manteinance mode*), que bloquea las acciones de otros usuarios, o
  permite sólo a los administradores logearse mientras está activado.
* Un **modo de usuario único** (*single-user mode*), que sólo permite el acceso
  del administrador al sistema.

Las opciones de administración quedan también disponibles en el fichero `owncloud/config/config.php`.

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
llevado a cabo.

Para mantener una coordinación sobre las instrucciones del protocolo, cada una
de ellas lleva un identificador de mensaje `MessageID`, que debe ser distinto
para cada una de las peticiones. El comportamiento sería indeterminado si un
cliente realizara varias peticiones bajo un mismo identificador. [@rfcLDAP]

Realizar la también la autenticación por el **protocolo WebDAV** es una opción
configurable. [@rfcWebDAV2]

### Gestión de extensiones

Las `apps` o extensiones de ownCloud que se están ejecutando en cada momento en
la nube son gestionadas por el admnistrador desde el comando `occ app`, que
permite las opciones:

* `app:enable`, `app:disable`, para habilitar o deshabilitar una extensión.
* `app:list`, para listar las extensiones disponibles.

Por ejemplo, para activar la autenticación de usuarios por `WebDAV`, vamos a
usar el comando `occ app:enable user_webdavauth`.


### Base de datos y LAMP

En la nube que estamos creando instalamos previamente un servidor **LAMP** con
una base de datos **MariaDB** que será la que usemos desde ownCloud para iniciar
el servicio. Esta instalación es requisito para el funcionamiento de ownCloud,
que requiere de un servidor web para acceder a él y de una base de datos.

Owncloud usa por defecto **SQLite**, pero esta es una base de datos sólo
recomendada para pruebas y no para entornos de producción. La elección de una
base de datos entre las instaladas puede realizarse al instalar ownCloud en la
pantalla de acceso inicial.

Para pasar a usar nuestro SGBD, necesitaremos crear un usuario que
pueda pasar a usar `ownCloud` y una base de datos dentro del sistema.
En nuestro caso, dentro del sistema de MySQL daremos permisos al usuario `owncloud` sobre una
base de datos que llamaremos `owncloud`.


### Control de versiones

Owncloud consta de un sistema de control de versiones simple que guarda copias
de seguridad y varias versiones históricas y las elimina según avanza el tiempo.
No facilita el cambio de este sistema por cualquier otro.

### Seguridad y acceso por SSH.

Parte de la motivación para gestionar una nube propia es la seguridad de los
datos.

Usaremos acceso a través de `ssh` mediante `openssh-server`.

### Aplicaciones

ownCloud basa su funcionalidad en ofrecer una serie de aplicaciones, tanto
propias de la aplicación como escritas por terceras partes. El servicio para
reunir esa oferta de aplicaciones es ownCloud Apps Store. [@owncloudapps]

## Monitorización y control de actividad

Una opción para monitorizar nuestra nube es usar las propias herramientas que
ofrece ownCloud. Estas nos proporcionan datos generales de uso del servidor y
del almacenamiento, pero no son capaces de obtener datos en más profundidad.
https://apps.owncloud.com/content/show.php/Storage+Usage+%2B+Activity+Charts?content=166746

Para comprobar simplemente que el servidor sigue funcionando, puede consultarse
el archivo `/owncloud/status.php`. Para obtener una traza detallada, puede
recurrirse al archivo `/owncloud/owncloud.log`.

Además, deben monitorizarse por separado los distintos componentes que forman la
estructura de ownCloud, como el servidor o la base de datos.



# AeroFS

AeroFS es una herramienta propietaria que permite la sincronización y
compartición de archivos para construir sobre ella una nube privada. Todo ello
administrado de manera centralizada y bajo el firewall privado. [@aerofs]

## Características

AeroFS usa la *AeroFS's Smart Routing Technology*
para sincronizar los datos dentro de la propia red interna, con la que el
fabricante afirma que mejora entre 10 y 100 veces la velocidad de otras
alternativas como *Dropbox*. [@aeroover] Aunque no se
proporcionan más detalles de la tecnología, podemos deducir de lo que el propio
fabricante afirma que se trata de permitir el enrutamiento directo de los
archivos compartidos por la intranet sin pasar por un servidor centralizado. Sin
embargo, no se nos ofrece información para contrastarlo:

*"Our Smart Routing technology keeps data
within the local LAN, taking advantage of the fact that most end-point routers and
switches are much faster than Internet uplinks."* (AeroFS Overview [@aeroover])

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
*DHCP* y una *IP estática* como opciones.

### Configuración del certificado SSL

El certificado SSL que usa AeroFS por defecto es autofirmado. Este es un
certificado que no está validado por ninguna autoridad certificadora (CA), y al
aceptarlo la primera, se acepta implícitamente que la identidad del expendedor
del certificado es de confianza. [@sslcrl] Esto causará que la mayoría de
navegadores web emitan un mensaje de alerta al acceder a la interfaz web de
AeroFS.

Cuando se posee un certificado reconocido por alguna autoridad
certificadora de confianza en formato PEM, puede usarse como certificado para el
servidor indicándolo en la sección de seguridad del apartado *Setup*, que pedirá
que indiquemos el certificado que pasará a usar a partir de ahora.



# Bibliografía
