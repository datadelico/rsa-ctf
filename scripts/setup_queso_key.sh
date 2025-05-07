#!/bin/bash

# Script para generar una clave SSH RSA segura para el usuario queso

# Configuración
KEY_DIR="docker/pasta-server/keys"  # Directorio donde se guarda la clave privada
QUESO_DIR="docker/queso-server/ssh"  # Directorio para authorized_keys en queso-server
KEY_FILE="id_rsa"
KEY_SIZE=4096  # Tamaño seguro para RSA
AUTHORIZED_KEYS="authorized_keys"

# Crear directorios si no existen
mkdir -p "$KEY_DIR"
mkdir -p "$QUESO_DIR"

echo "Generando clave SSH RSA segura para el usuario queso..."
# Generar clave SSH RSA de 4096 bits sin frase de contraseña forzar la creación de la clave
# y asegurarse de que no se sobrescriba una clave existente
if [ -f "$KEY_DIR/$KEY_FILE" ]; then
    echo "Advertencia: La clave privada ya existe. Se sobrescribirá."
    rm -f "$KEY_DIR/$KEY_FILE" "$KEY_DIR/$KEY_FILE.pub"
fi
ssh-keygen -t rsa -b $KEY_SIZE -f "$KEY_DIR/$KEY_FILE" -N "" 

# Extraer la clave pública para authorized_keys y colocarla en queso-server
cat "$KEY_DIR/$KEY_FILE.pub" > "$QUESO_DIR/$AUTHORIZED_KEYS"

# Establecer permisos correctos
chmod 700 "$KEY_DIR"
chmod 600 "$KEY_DIR/$KEY_FILE"
chmod 600 "$KEY_DIR/$KEY_FILE.pub"
chmod 600 "$QUESO_DIR/$AUTHORIZED_KEYS"

echo "Clave RSA segura generada correctamente:"
echo "- Clave privada (para cifrar): $KEY_DIR/$KEY_FILE"
echo "- Clave pública: $KEY_DIR/$KEY_FILE.pub"
echo "- Authorized keys (para queso-server): $QUESO_DIR/$AUTHORIZED_KEYS"
