# CTF Challenge: Pasta's Password Vault

## Introducción

¡Bienvenido al servidor de Pasta!
Para acceder al servidor **pasta-server**, el usuario `pasta`tien la contraseña `tomate` (sin comillas).
El usuario `pasta` es un experto en seguridad informática y ha implementado un sistema de cifrado para proteger su información sensible. Sin embargo, su enfoque de seguridad tiene una debilidad crítica.
Pasta ha protegido su clave SSH para acceder al servidor **queso-server** (usuario `queso`) mediante una contraseña secreta. A su vez, esa contraseña está almacenada en un archivo cifrado con una clave RSA débil.

## Archivos disponibles

- **`/home/pasta/public_key.pem`**  
    Clave pública RSA de sólo 256 bits.

- **`/home/pasta/encrypted_flag.bin`**  
    Contiene la "flag" cifrada con la clave pública anterior.

- **`/home/pasta/encrypted_ssh_key.bin`**  
    Clave SSH cifrada usando la flag como contraseña.

## Objetivo

1. Factoriza la clave RSA de 256 bits para obtener la clave privada.
2. Descifra `encrypted_flag.bin` y recupera la flag.
3. Usa la flag como contraseña para descifrar `encrypted_ssh_key.bin`.
4. Conéctate vía SSH al servidor queso-server con el usuario queso.

## Comandos disponibles

```
cd    # Navegar carpetas
ls    # Listar archivos
cat   # Mostrar contenido (solo para texto)
ssh   # Conexión SSH
base64 # Codificar/decodificar en Base64
```

> **Consejo**: Los archivos cifrados están en formato binario. Para verlos o transferirlos por canales que admiten solo texto, emplea base64.

## Sugerencias para la factorización

- Utiliza **SageMath** junto con bibliotecas de python (por ejemplo, `cryptography`).
- Echa un vistazo a proyectos especializados como **RsaCtfTool**, que automatizan gran parte del proceso.

## Comandos originales de cifrado

```bash
openssl enc -aes-256-cbc -salt -in "$SSH_KEY" -out "$ENCRYPTED_SSH_KEY" -pass "pass:$FLAG_CONTENT"
openssl pkeyutl -encrypt -pubin -inkey "$PUBLIC_KEY" -in "$FLAG_FILE" -out "$ENCRYPTED_FLAG"
```

¡Adelante, factoriza la RSA y descubre la contraseña que te dará acceso al servidor!
