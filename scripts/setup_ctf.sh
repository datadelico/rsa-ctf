#!/bin/bash
set -e  # Detener en caso de error

echo "=== Configurando CTF RSA ==="

# 1. Generar claves RSA débiles (512 bits)
echo "Generando claves RSA débiles..."
python3 scripts/generate_weak_rsa.py

# 2. Generar claves SSH para queso
echo "Generando claves SSH para queso..."
bash scripts/setup_queso_key.sh

# 3. Construir y levantar contenedores
echo "Levantando contenedores Docker..."
docker compose down
docker compose build
docker compose up -d

echo "¡CTF listo! SSH disponible en localhost:2223 (usuario: pasta, password: tomate)"