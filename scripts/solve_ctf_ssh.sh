#!/bin/bash

# Script para descifrar la clave SSH recuperando primero la flag

set -e  # Detener en caso de error

# Configuración predeterminada
PRIVATE_KEY="recovered_private_key.pem"
ENCRYPTED_FLAG="encrypted_flag.bin"
ENCRYPTED_SSH_KEY="encrypted_ssh_key.bin"
OUTPUT_SSH_KEY="recovered_id_rsa"
SSH_USER="pasta"
SSH_PASSWORD="tomate"
SSH_HOST="localhost"
SSH_PORT="2223"
OUTPUT_DIR="$(pwd)"

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Descifra la clave SSH recuperando primero la flag usando solo SSH"
    echo ""
    echo "Opciones:"
    echo "  -p, --private-key ARCHIVO    Clave RSA privada recuperada"
    echo "  -u, --user USUARIO           Usuario SSH (default: pasta)"
    echo "  -w, --password CONTRASEÑA    Contraseña SSH (default: tomate)"
    echo "  -h, --host HOST              Host SSH (default: localhost)"
    echo "  -P, --port PUERTO            Puerto SSH (default: 2223)"
    echo "  -d, --dir DIRECTORIO         Directorio de salida (default: directorio actual)"
    echo "  -o, --output ARCHIVO         Nombre de archivo de salida para clave SSH"
    echo "  --help                       Muestra esta ayuda"
    echo ""
}

# Procesar argumentos
while [ "$1" != "" ]; do
    case $1 in
        -p | --private-key )    shift
                                PRIVATE_KEY=$1
                                ;;
        -u | --user )           shift
                                SSH_USER=$1
                                ;;
        -w | --password )       shift
                                SSH_PASSWORD=$1
                                ;;
        -h | --host )           shift
                                SSH_HOST=$1
                                ;;
        -P | --port )           shift
                                SSH_PORT=$1
                                ;;
        -d | --dir )            shift
                                OUTPUT_DIR=$1
                                ;;
        -o | --output )         shift
                                OUTPUT_SSH_KEY=$1
                                ;;
        --help )                show_help
                                exit
                                ;;
        * )                     show_help
                                exit 1
    esac
    shift
done

echo "=== RESOLUCIÓN AUTOMATIZADA DEL CTF RSA (USANDO SOLO SSH) ==="

# Verificar si sshpass está instalado
if ! command -v sshpass &> /dev/null; then
    echo "El comando 'sshpass' no está instalado. Instálalo con:"
    echo "sudo apt-get install sshpass"
    exit 1
fi

# Crear directorio de salida
mkdir -p "$OUTPUT_DIR"

# Paso 1: Extraer archivos del servidor mediante SSH
echo "Paso 1: Extrayendo archivos mediante SSH ($SSH_USER@$SSH_HOST:$SSH_PORT)..."

# Extraer public_key.pem (archivo de texto)
echo "- Extrayendo clave pública..."
sshpass -p "$SSH_PASSWORD" ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no "$SSH_USER@$SSH_HOST" "cat /home/pasta/public_key.pem" > "$OUTPUT_DIR/public_key.pem"

# Extraer encrypted_flag.bin (archivo binario)
echo "- Extrayendo flag cifrada..."
sshpass -p "$SSH_PASSWORD" ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no "$SSH_USER@$SSH_HOST" "cat /home/pasta/encrypted_flag.bin | base64" | base64 -d > "$OUTPUT_DIR/$ENCRYPTED_FLAG"

# Extraer encrypted_ssh_key.bin (archivo binario)
echo "- Extrayendo clave SSH cifrada..."
sshpass -p "$SSH_PASSWORD" ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no "$SSH_USER@$SSH_HOST" "cat /home/pasta/encrypted_ssh_key.bin | base64" | base64 -d > "$OUTPUT_DIR/$ENCRYPTED_SSH_KEY"

echo "✓ Archivos extraídos correctamente a $OUTPUT_DIR"

# Paso 2: Verificar si ya existe la clave privada o necesitamos factorizar
if [ ! -f "$PRIVATE_KEY" ]; then
    echo "Paso 2: La clave privada no existe, necesitamos factorizar la clave RSA..."
    echo "Ejecutar el siguiente comando para factorizar la clave:"
    echo "sage -python scripts/crack_rsa.py $OUTPUT_DIR/public_key.pem"
    echo "Después, vuelve a ejecutar este script con la clave privada generada."
    exit 1
fi

# Paso 3: Descifrar la flag usando la clave privada
echo "Paso 3: Descifrando la flag con la clave RSA privada recuperada..."
openssl pkeyutl -decrypt -inkey "$PRIVATE_KEY" -in "$OUTPUT_DIR/$ENCRYPTED_FLAG" -out "$OUTPUT_DIR/recovered_flag.txt"

# Paso 4: Leer la flag y mostrarla
echo "Paso 4: Leyendo la flag recuperada..."
FLAG_CONTENT=$(cat "$OUTPUT_DIR/recovered_flag.txt")
echo "Flag recuperada: $FLAG_CONTENT"

# Paso 5: Descifrar la clave SSH usando la flag como contraseña
echo "Paso 5: Descifrando la clave SSH usando la flag como contraseña..."
openssl enc -d -aes-256-cbc -in "$OUTPUT_DIR/$ENCRYPTED_SSH_KEY" -out "$OUTPUT_DIR/$OUTPUT_SSH_KEY" -pass "pass:$FLAG_CONTENT"

# Configurar permisos adecuados para la clave SSH
chmod 600 "$OUTPUT_DIR/$OUTPUT_SSH_KEY"

# Paso 6: Conectar al servidor SSH usando la clave privada recuperada
echo "Paso 6: Conectando al servidor SSH usando la clave privada recuperada y"
ssh -i "$OUTPUT_DIR/$OUTPUT_SSH_KEY" -J pasta@localhost:2223 queso@queso-server
echo "=== OBTENIENDO FLAG MEDIANTE PIVOTING A TRAVÉS DE PASTA ==="
cat flag.txt
echo "=== FLAG FINAL OBTENIDA MEDIANTE PIVOTING ==="
echo "¡Felicidades! Has completado el CTF exitosamente usando técnicas de pivoting."