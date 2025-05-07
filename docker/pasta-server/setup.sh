#!/bin/bash

# Script para configurar el contenedor de pasta-server


# Configurar directorio PATH limitado para rbash
mkdir -p /home/pasta/bin
ln -sf /bin/ls /home/pasta/bin/ls
ln -sf /bin/cat /home/pasta/bin/cat
ln -sf /bin/cd /home/pasta/bin/cd
ln -sf /usr/bin/ssh /home/pasta/bin/ssh
ln -sf /usr/bin/base64 /home/pasta/bin/base6


# Cambiar los permisos del directorio /home/pasta/bin y los enlaces simbólicos
chmod -R 751 /home/pasta/bin
# Ubicaciones de archivos
SSH_KEY="/home/pasta/.ssh/id_rsa"
PUBLIC_KEY="/home/pasta/public_key.pem"
PRIVATE_KEY="/home/pasta/private_key.pem"
FLAG_FILE="/home/pasta/flag.txt"
ENCRYPTED_SSH_KEY="/home/pasta/encrypted_ssh_key.bin"
ENCRYPTED_FLAG="/home/pasta/encrypted_flag.bin"


# Verificar que los archivos existen y cifrarlos
if [ -f "$SSH_KEY" ] && [ -f "$PUBLIC_KEY" ] && [ -f "$FLAG_FILE" ]; then
    # Leer flag
    FLAG_CONTENT=$(cat $FLAG_FILE)
    
    # Cifrado de archivos
    openssl enc -aes-256-cbc -salt -in "$SSH_KEY" -out "$ENCRYPTED_SSH_KEY" -pass "pass:$FLAG_CONTENT"
    openssl pkeyutl -encrypt -pubin -inkey "$PUBLIC_KEY" -in "$FLAG_FILE" -out "$ENCRYPTED_FLAG"
    
    # Eliminar originales
    rm -f "$FLAG_FILE"
    rm -f "$SSH_KEY"
    rm -f "$PRIVATE_KEY"
else
    echo "Advertencia: No se encontraron todos los archivos necesarios"
fi

# Iniciar servicio SSH
service ssh start

# Mantener el contenedor en ejecución
tail -f /dev/null