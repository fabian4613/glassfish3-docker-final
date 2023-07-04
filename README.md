# glassfish3-docker-final
## Glassfish 3.1.2.2 - Acceso al panel de administración desde una conexión remota sin HTTPS

Este documento te guía en la configuración para habilitar el acceso al panel de administración de Glassfish 3.1.2.2 sin utilizar HTTPS desde una conexión remota en Docker.

### Pasos a seguir:

1. Ejecuta el siguiente comando en tu terminal para crear la imagen:

```bash
docker build -t glassfish3 .
```

2. Ejecuta el siguiente comando en tu terminal para arrancar el contenedor:

```bash
docker run -dit --name glassfish3container -p 25:22 glassfish3
```

Este comando inicia un nuevo contenedor Docker llamado glassfish3container con OpenSSH-Server instalado y activado.

Una vez que el contenedor está en ejecución, configura el glassfish de manera manual a tus necesidades (acuerdate de definir una contraseña [asadmin change-admin-password]) e inicia el dominio. Luego realiza un reenvío del puerto 4848 en tu PC local (por ejemplo, usando Mobaxterm) hacia la IP del host donde Docker está instalado y al puerto SSH 25. Esto permite que el panel de administración de Glassfish sea accesible desde tu PC local.
Al finalizar estos pasos, podrás acceder al panel de administración de Glassfish desde tu PC local sin encontrar errores de DAS (Domain Administration Server).

### Ingresar al Container

Si deseas ingresar al contenedor creado, puedes hacer lo siguiente:

```bash
docker exec -u glassfish -it glassfish3container /bin/bash
```
