FROM ubuntu:24.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    rsyslog \
    auditd \
    && rm -rf /var/lib/apt/lists/*

# Crear el usuario queso con contraseña "queso"
RUN useradd -m queso && echo "queso:queso" | chpasswd 

# Configurar SSH
RUN mkdir /var/run/sshd
RUN chmod 700 /home/queso

# Crear directorio .ssh antes de copiar archivos
RUN mkdir -p /home/queso/.ssh
RUN chmod 700 /home/queso/.ssh

# Restricciones para el usuario (shell restringido)
RUN chsh -s /bin/rbash queso

# Configurar PATH restringido y enlaces simbólicos para comandos permitidos
RUN mkdir -p /home/queso/bin
RUN ln -sf /bin/ls /home/queso/bin/ls
RUN ln -sf /bin/cat /home/queso/bin/cat
RUN ln -sf /usr/bin/ssh /home/queso/bin/ssh

# Copiar el .bashrc reforzado
COPY skel/.bashrc /home/queso/.bashrc
RUN chmod 444 /home/queso/.bashrc
RUN chown root:root /home/queso/.bashrc

# Copiar flag
COPY flag.txt /home/queso/flag.txt
RUN chmod 444 /home/queso/flag.txt

# Configuración SSH
COPY ssh/sshd_config /etc/ssh/sshd_config
RUN chmod 600 /etc/ssh/sshd_config
RUN chown root:root /etc/ssh/sshd_config

# Copiar authorized_keys
COPY ssh/authorized_keys /home/queso/.ssh/authorized_keys
RUN chmod 600 /home/queso/.ssh/authorized_keys
RUN chown -R queso:queso /home/queso/.ssh  

# Asegurar permisos del directorios
RUN chown -R root:root /home/queso/bin
RUN chmod 711 /home/queso/bin
RUN chmod 555 /home/queso/bin/ls
RUN chmod 555 /home/queso/bin/cat
RUN chmod 555 /home/queso/bin/ssh

# Ajustar permisos del directorio home
RUN chmod 755 /home/queso
RUN chmod 700 /home/queso/.ssh

# Deshabilitar el mensaje de bienvenida (MOTD)
RUN chmod -x /etc/update-motd.d/*

# Clear legal file
RUN echo "" > /etc/legal
RUN echo "" > /etc/issue
RUN echo "" > /etc/issue.net

# Puerto SSH
EXPOSE 22

# Iniciar servicio SSH
CMD ["/usr/sbin/sshd", "-D"]
