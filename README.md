[![](https://images.microbadger.com/badges/image/siutoba/docker-web.svg)](https://microbadger.com/images/siutoba/docker-web "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/siutoba/docker-web.svg)](http://microbadger.com/images/siutoba/docker-web "Get your own version badge on microbadger.com")

# docker-web
Contenedor Docker que sirve como base para proyectos basados en SIU-Toba. 
Este paquete se encuentra deprecado, ver [siu-toba/docker](https://github.com/SIU-Toba/docker) como futuro reemplazo.

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
Para que esto funcione los containers involucrados deben compartir un volumen comun publicado en `/var/local/docker-data/containers-status`

## Variables de entorno relevantes
 * `COMPOSER_SIU_USER` y `COMPOSER_SIU_PASS`: Utilizadas para configurar el acceso al repositorio GIT del SIU
 * `DOCKER_WEB_SCRIPT`: Path a un script ejecutado dentro del contenedor como último paso del ENTRYPOINT
 * `ENABLE_SSL`: Permite que el webserver se configure para brindar acceso via SSL.
 * `DOCKER_CERT_FILE`, `DOCKER_KEY_FILE`y `DOCKER_CHAIN_FILE`: Permiten especificar las rutas a los archivos de certificados, clave privada y cadena de CA's en formato pem para configurar el virtualhost
 * `DOCKER_SSL_PORT`: Especifica que puerto se mapea desde el host (util para redirects).
 
## Build
Para buildear manualmentel la imagen
```
docker build -t="siutoba/docker-web" .
```
