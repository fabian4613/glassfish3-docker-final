FROM ubuntu:mantic-20230624

# Install base packages
RUN yes | unminimize

# Set environment variables
ENV GLASSFISH_PKG=/tmp/glassfish-3.1.2.2.zip \
    GLASSFISH_URL=http://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip \
    GLASSFISH_HOME=/usr/local/glassfish3 \
    MD5=ae8e17e9dcc80117cb4b39284302763f \
    PATH=$PATH:/usr/local/glassfish3/bin

# Update packages and install necessary dependencies
RUN apt-get update && apt-get install -y wget unzip expect

# Download and install OpenJDK 8
RUN apt-get install -y openjdk-8-jdk

# Install sudo, OpenSSH, vim and nano
RUN apt-get install -y openssh-server sudo vim nano

# Create new sudo user
RUN useradd -rm -d /home/glassfish -s /bin/bash -g root -G sudo -u 04613 glassfish

# Update user password
RUN echo 'glassfish:admin' | chpasswd

# Give sudo permission without password
RUN echo 'glassfish ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Create the GlassFish directory and set permissions
RUN mkdir -p $GLASSFISH_HOME && chown -R glassfish:root $GLASSFISH_HOME

# Modificar el perfil del usuario y de root para incluir las variables de entorno
RUN echo 'export GLASSFISH_PKG=/tmp/glassfish-3.1.2.2.zip' | tee -a /home/glassfish/.bashrc /root/.bashrc && \
    echo 'export GLASSFISH_URL=http://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip' | tee -a /home/glassfish/.bashrc /root/.bashrc && \
    echo 'export GLASSFISH_HOME=/usr/local/glassfish3' | tee -a /home/glassfish/.bashrc /root/.bashrc && \
    echo 'export MD5=ae8e17e9dcc80117cb4b39284302763f' | tee -a /home/glassfish/.bashrc /root/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/glassfish3/bin' | tee -a /home/glassfish/.bashrc /root/.bashrc

# Download and install GlassFish
RUN wget -q -O $GLASSFISH_PKG $GLASSFISH_URL && \
    echo "$MD5 *$GLASSFISH_PKG" | md5sum -c - && \
    unzip -o $GLASSFISH_PKG -d /usr/local && \
    rm -f $GLASSFISH_PKG && \
    \
    # Remove Windows .bat and .exe files to save space
    cd $GLASSFISH_HOME && \
    find . -name '*.bat' -delete && \
    find . -name '*.exe' -delete

# Establece las variables de entorno en asenv.conf
RUN echo "AS_JAVA=/usr/lib/jvm/java-8-openjdk-amd64" >> $GLASSFISH_HOME/glassfish/config/asenv.conf && \
    echo "OTRA_VARIABLE=valor" >> $GLASSFISH_HOME/glassfish/config/asenv.conf

# Agregar jre-1.8=${jre-1.7} a osgi.properties
RUN echo 'jre-1.8=${jre-1.7}' >> $GLASSFISH_HOME/glassfish/config/osgi.properties

# Copy the change password script into the container
COPY change_password.sh /change_password.sh
RUN chmod +x /change_password.sh

# Ports being exposed
EXPOSE 4848 8080 8181 22

WORKDIR $GLASSFISH_HOME

# Copia los archivos WAR locales al directorio autodeploy de GlassFish
COPY prueba2grupo1.war prueba2grupo2.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/

# Ejecuta el script de cambio de contraseña
RUN /change_password.sh

# Mantener el contenedor activo con /bin/sh
CMD service ssh start && /bin/bash
