---
title: "Cómo montar una nube"
author: Mario Román García
date: Universidad de Granada
abstract: "Resumen aquí"
mainfont: Arial
fontsize: 10pt
geometry: "a4paper, top=2.5cm, bottom=2.5cm, left=3cm, right=3cm"

bibliography: references.bib
---

# Owncloud

Owncloud proporciona software de servidor y de cliente para montar una
nube. Permite acceder a los datos mediante una interfaz web o mediante el
protocolo  **WebDAV**.


## Owncloud como usuario

La instalación en sistemas Debian puede realizarse mediante:

```bash
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_14.10/ /' >> /etc/apt/sources.list.d/owncloud.list"
sudo apt-get update
sudo apt-get install owncloud
```

# Openstack
