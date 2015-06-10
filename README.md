# docker-web
Contenedor Docker que sirve como base para proyectos basados en SIU-Toba.

## Uso
Los proyectos que quieran utilizar este proyecto deberán basar sus imagenes desde **siutoba/docker-web** usando FROM en el Dockerfile
del proyecto:

```
FROM siutoba/docker-web
```

Si se desea correr algún script de ENTRYPOINT específico, como será el caso de la mayoría de los proyectos, en el Dockerfile
del proyecto hay que agregarlos a la carpeta **/entrypoint.d**. Por ejemplo:

```
FROM siutoba/docker-web
COPY guarani.sh /entrypoint.d/
RUN chmod +x /entrypoint.d/guarani.sh 
```

Actualmente esta imagen está basada en la [oficial de PHP](https://registry.hub.docker.com/_/php/). Si se quieren agregar
extensiones a PHP se debe leer la [documentación](https://registry.hub.docker.com/_/php/) o ver, a modo de ejemplo, el Dockerfile
de esta imagen. 

## Arranque secuencial de containers
Esta imagen lee un par de variables de entorno que permite encadenar el arranque de los containers
```
    DOCKER_NAME		: Nombre del container, ejemplo "mi_aplicacion"
    DOCKER_WAIT_FOR	: Nombre del container al cual esperar por ejemplo "otra_aplicacion"
```
Para que esto funcione los containers involucrados deben compartir un volumen comun publicado en `/var/local/containers-status`


## Build
Para buildear manualmentel la imagen
```
docker build -t="siutoba/docker-web" .
```
