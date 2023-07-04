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

# Modificar el perfil del usuario para incluir la variable PATH
RUN echo 'export PATH=$PATH:/usr/local/glassfish3/bin' >> /home/glassfish/.bashrc

# Copy the startup script into the container
COPY startup_script.sh /startup_script.sh
RUN chmod +x /startup_script.sh

# Ejecutar script
RUN /startup_script.sh

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

# Ports being exposed
EXPOSE 4848 8080 22

WORKDIR $GLASSFISH_HOME

# Copia los archivos WAR locales al directorio autodeploy de GlassFish
COPY prueba2grupo1.war prueba2grupo2.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/

# Mantener el contenedor activo con /bin/sh
CMD ["/bin/bash"]
