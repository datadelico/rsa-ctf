FROM ubuntu:24.04

# Instalar solo paquetes estrictamente necesarios
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssl \
    rsyslog \
    auditd \
    && rm -rf /var/lib/apt/lists/*

# Eliminar mensajes de bienvenida de Ubuntu
RUN rm -f /etc/update-motd.d/*
RUN rm -f /etc/legal /etc/motd
RUN touch /etc/motd

# Crear un skel restrictivo más seguro para pasta
RUN mkdir -p /etc/skel_pasta
# Copiar archivos de configuración del esqueleto
COPY skel/.profile /etc/skel_pasta/.profile
COPY skel/.bashrc /etc/skel_pasta/.bashrc
RUN chmod 444 /etc/skel_pasta/.profile /etc/skel_pasta/.bashrc
RUN chown root:root /etc/skel_pasta/.profile /etc/skel_pasta/.bashrc

# Crear usuario pasta con skel personalizado
RUN useradd -m -k /etc/skel_pasta -s /bin/rbash pasta 
RUN echo "pasta:tomate" | chpasswd

# Configurar SSH
RUN mkdir /var/run/sshd

# Crear directorios necesarios con permisos adecuados
RUN mkdir -p /home/pasta/.ssh
RUN chmod 700 /home/pasta/.ssh
RUN mkdir -p /home/pasta/bin
RUN chmod 500 /home/pasta/bin

# Permitir SOLO los comandos estrictamente necesarios (eliminando cd y limitando ssh)
RUN ln -sf /bin/ls /home/pasta/bin/ls && \
    ln -sf /usr/bin/base64 /home/pasta/bin/base64 && \
    ln -sf /usr/bin/ssh /home/pasta/bin/ssh

# Copiar claves SSH
COPY ./keys/id_rsa /home/pasta/.ssh/id_rsa
COPY ./keys/public_key.pem /home/pasta/public_key.pem
COPY ./keys/private_key.pem /home/pasta/private_key.pem

# Establecer permisos correctos
RUN chmod 400 /home/pasta/.ssh/id_rsa  
RUN chmod 444 /home/pasta/public_key.pem  
RUN chmod 400 /home/pasta/private_key.pem  
RUN chown pasta:pasta /home/pasta/.ssh/id_rsa

# Configuración SSH reforzada
COPY ./ssh/sshd_config /etc/ssh/sshd_config
RUN chmod 600 /etc/ssh/sshd_config

# Copiar flag
COPY flag.txt /home/pasta/flag.txt
RUN chown pasta:pasta /home/pasta/flag.txt
RUN chmod 400 /home/pasta/flag.txt

# Copiar README.md con instrucciones
COPY README.md /home/pasta/README.md
RUN chmod 444 /home/pasta/README.md 
# Establecer propiedad y permisos adecuados del directorio bin
RUN chown -R root:root /home/pasta/bin
RUN chmod 555 /home/pasta/bin/*

# Puerto SSH
EXPOSE 22

# Copiar script de configuración
COPY setup.sh /setup.sh
RUN chown root:root /setup.sh
RUN chmod 500 /setup.sh 
# Ejecutar script de configuración
CMD ["/setup.sh"]