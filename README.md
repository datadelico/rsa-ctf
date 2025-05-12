# CTF-RSA: Criptografía, Factorización y Escalada de Privilegios

Este proyecto implementa un Capture The Flag (CTF) educativo centrado en vulnerabilidades criptográficas de RSA con claves débiles. Los participantes deben factorizar una clave RSA de 256 bits para obtener acceso a un servidor protegido.

## Descripción del Reto

El CTF simula un escenario donde hay dos servidores (contenedores Docker):

1. **Servidor pasta**: Punto de entrada con credenciales conocidas (`pasta:tomate`). Este servidor contiene una clave RSA pública débil y archivos cifrados.

2. **Servidor queso**: Contiene la flag final, solo accesible mediante SSH con una clave privada que debe ser obtenida descifrando archivos del servidor pasta.

## Estructura del Proyecto

```
rsa-ctf/
├── docker-compose.yml           # Configuración de contenedores Docker
├── README.md                    # Este archivo de documentación
├── docker/                      # Configuración de contenedores
│   ├── pasta-server/            # Servidor inicial (punto de entrada)
│   │   ├── Dockerfile           # Configuración del contenedor
│   │   ├── flag.txt             # Flag intermedia cifrada con RSA
│   │   ├── setup.sh             # Script de inicialización
│   │   └── keys/                # Claves criptográficas
│   │       ├── id_rsa           # Clave SSH que será cifrada
│   │       └── public_key.pem   # Clave RSA pública débil (256 bits)
│   └── queso-server/            # Servidor final con la flag
│       ├── Dockerfile           # Configuración del contenedor
│       ├── flag.txt             # Flag final
│       └── ssh/                 # Configuración SSH
│           └── authorized_keys  # Claves autorizadas
└── scripts/                     # Scripts de configuración y resolución
    ├── generate_weak_rsa.py     # Genera claves RSA débiles (256 bits)
    ├── crack_rsa.py             # Script para factorizar la clave RSA
    ├── setup_queso_key.sh       # Configura claves SSH para queso-server
    ├── setup_ctf.sh             # Script maestro de configuración
    └── solve_ctf_ssh.sh         # Script para resolver el CTF automáticamente
```
## Conceptos criptográficos aplicados

- **RSA con claves débiles**: Las claves RSA de 256 bits son factorizables en segundos
- **Factorización de números primos**: Ataque fundamental contra RSA
- **Shell restringida (rbash)**: Limitación del entorno del usuario
- **Pivoting**: Acceso a sistemas internos pasando por sistemas intermedios

## Requisitos del Sistema

Para ejecutar este CTF necesitarás:

```bash
# Instalación básica
sudo apt update
sudo apt install -y python3 python3-pip docker docker-compose

# Instalación de bibliotecas Python
pip3 install cryptography

# Instalación de SageMath (necesario para factorización RSA)
sudo apt install -y sagemath

# Instalación de sshpass (opcional, para automatizar SSH con contraseña)
sudo apt install -y sshpass
```

## Configuración del CTF

Para configurar y levantar el CTF:

```bash
# Clonar el repositorio
git clone https://github.com/datadelico/rsa-ctf.git
cd rsa-ctf

# Ejecutar script de configuración completo
bash scripts/setup_ctf.sh
```

Este script automáticamente:
1. Genera claves RSA débiles (256 bits)
2. Crea claves SSH para comunicación entre servidores
3. Levanta los contenedores Docker

## Resolviendo el CTF 

### Conéctate al servidor pasta

```bash
ssh -o StrictHostKeyChecking=no pasta@localhost -p 2223
# Contraseña: tomate
```

### Obtenemos la clave pública y archivos cifrados

#### Con SSH normal (interactivo):

```bash
ssh -o StrictHostKeyChecking=no pasta@localhost -p 2223 'base64 public_key.pem' | base64 -d > public_key.pem
ssh -o StrictHostKeyChecking=no pasta@localhost -p 2223 'base64 encrypted_flag.bin' | base64 -d > encrypted_flag.bin
ssh -o StrictHostKeyChecking=no pasta@localhost -p 2223 'base64 encrypted_ssh_key.bin' | base64 -d > encrypted_ssh_key.bin
```

#### Con sshpass (acceso automático):

```bash
sshpass -p 'tomate' ssh -o StrictHostKeyChecking=no pasta@localhost -p 2223 'base64 public_key.pem'| base64 > public_key.pem
sshpass -p 'tomate' ssh -o StrictHostKeyChecking=no pasta@localhost -p 2223 'base64 encrypted_flag.bin' | base64 -d > encrypted_flag.bin
sshpass -p 'tomate' ssh -o StrictHostKeyChecking=no pasta@localhost -p 2223 'base64 encrypted_ssh_key.bin' | base64 -d > encrypted_ssh_key.bin
```

### Factoriza la clave RSA con SageMath

```
sage -python scripts/crack_rsa.py public_key.pem
```

### Descifra la flag usando la clave privada recuperada:

```python
openssl pkeyutl -decrypt -inkey recovered_key.pem -in encrypted_flag.bin -out flag.txt
cat flag.txt
#flag{F4ct0r1z4t10n}
```

### Usa esta flag como contraseña para descifrar la clave SSH:
```bash
openssl enc -d -aes-256-cbc -in encrypted_ssh_key.bin -out id_rsa -pass "pass:flag{F4ct0r1z4t10n}"
chmod 600 id_rsa
```
#### Conéctate al servidor queso pivotando desde el servidor pasta usando la clave SSH recuperada:

```bash
sshpass -p 'tomate' ssh -o StrictHostKeyChecking=no -i id_rsa -J pasta@localhost:2223 queso@queso-server
cat flag.txt
```

## Solución de problemas comunes

### Problemas con archivos binarios
```bash
# Verificar que los archivos binarios se transfirieron correctamente
hexdump -C encrypted_flag.bin | head
hexdump -C encrypted_ssh_key.bin | head
```

### Problemas con Docker
```bash
# Verificar estado de contenedores
docker ps -a

# Ver logs de contenedores
docker logs pasta-server
docker logs queso-server

# Reiniciar contenedores
docker compose down
docker compose up -d
```

### Problemas con SageMath
```bash
# Verificar instalación de SageMath
sage -v

# Probar factorización simple
sage -c "print(factor(143))"  # Debe mostrar 11*13
```

## Notas educativas

Este CTF demuestra por qué:
1. Las claves RSA deben tener al menos 2048 bits en entornos de producción
2. Los números primos usados en RSA deben ser generados aleatoriamente
3. Las restricciones de shell pueden ser vulnerables a técnicas de escape

---

Este CTF está diseñado con fines educativos para comprender las vulnerabilidades en implementaciones RSA con claves de tamaño insuficiente y la importancia de usar parámetros criptográficos adecuados en entornos de producción.