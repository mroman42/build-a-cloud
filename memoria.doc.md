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
nube privada orientada al almacenamiento y a la compartición de
archivos. Owncloud es software libre, licenciado bajo la Affero
General Public License. Nació como parte del proyecto **KDE** para permitir a los
usuarios control de sus archivos y se independizó como *ownCloud Inc.*,
ofreciendo soporte empresarial. [@owncloudhistory]

Permite acceder a los datos mediante una interfaz web o mediante el protocolo
**WebDAV**. El núcleo del servidor de ownCloud está escrito en **PHP**, con el
cliente de escritorio escrito en **C++**. Todo el código fuente puede
consultarse directamente desde repositorios públicos. [@owncloudgit]

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
[@ownadmin], y la haremos funcionar sobre un sistema *GNU/Linux*.
Construiremos nuestra nube con ownCloud sobre una máquina virtual usando
**Virtual Box** como software de virtualización y usaremos **Ubuntu Server
14.04** para 64 bits como
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
además de para plataformas móviles como **Android**.


## Owncloud como administrador

Como administradores, podemos seguir el manual de administración de ownCloud. [@ownadmin]

La mayoría de operaciones de administración pueden realizarse a través de una
interfaz de línea de comandos escrita como un script de PHP situado en la
carpeta `var/www/owncloud/`. Puede invocarse con el comando `occ`.

Esto nos permite varias funciones de mantenimiento:

* Un **modo de mantenimiento**, que bloquea las acciones de otros usuarios, o
  permite sólo a los administradores logearse mientras está activado.

### Gestión de usuarios

Los privilegios del usuario serán controlados por el administrador y
establecidos para cada uno de los usuarios independientemente. Owncloud soporta
el uso de grupos de usuarios, cuotas de disco y el nombramiento de varios
subadministradores entre los usuarios. La gestión se puede realizar por medio de
`occ user`.

Para configurar los permisos sobre ownCloud, el usuario de HTTP del sistema debe
tener control sobre el directorio de ownCloud. Este usuario varía según la
distribución que se esté usando. En Ubuntu, el usuario de HTTP es
`www-data`. Para averiguarlo en una distribución Linux cualquiera, puede
ejecutarse el siguiente script en PHP:

```php
<?php echo exec('whoami'); ?>
```

La autenticación de los usuarios se hace mediante el uso del **protocolo LDAP**
(*Lightweight Directory Access Protocol*). [@rfcLDAP]

### Base de datos y LAMP

En la nube que estamos creando instalamos previamente un servidor **LAMP** con una
base de datos **MariaDB** que será la que usemos desde ownCloud para iniciar el
servicio. Esta instalación es requisito para el funcionamiento de ownCloud, que
requiere de un servidor web para acceder a él y de una base de datos.

Owncloud usa por defecto **SQLite**, pero esta es una base de datos sólo recomendada
para pruebas y no para entornos de producción. La elección de una base de datos
entre las instaladas puede realizarse al instalar ownCloud.


### Control de versiones

Owncloud consta de un sistema de control de versiones simple que guarda copias
de seguridad y varias versiones históricas y las elimina según avanza el tiempo.

### Seguridad y acceso por SSH.

Parte de la motivación para gestionar una nube propia es la seguridad de los
datos.

Usaremos acceso a través de `ssh` mediante `openssh-server`.

### Aplicaciones

ownCloud basa su funcionalidad en ofrecer una serie de aplicaciones, tanto
propias de la aplicación como escritas por terceras partes. El servicio para
reunir esa oferta de aplicaciones es ownCloud Apps Store. [@owncloudapps]

### Monitorización y control de actividad

Una opción para monitorizar nuestra nube es usar las propias herramientas que
ofrece ownCloud. Estas nos proporcionan datos generales de uso del servidor y
del almacenamiento, pero no son capaces de obtener datos en más profundidad.
https://apps.owncloud.com/content/show.php/Storage+Usage+%2B+Activity+Charts?content=166746

# Openstack
