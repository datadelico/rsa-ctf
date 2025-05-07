=== CTF Challenge: Pasta's Password Vault ===

¡Bienvenido al servidor de pasta!

He guardado mi clave SSH para acceder al servidor queso-server para el usuario queso, pero la cifré usando una contraseña importante.
Esa contraseña está en un archivo cifrado con una clave RSA débil.

Archivos importantes:
- /home/pasta/public_key.pem: Clave pública RSA débil (256 bits)
- /home/pasta/encrypted_flag.bin: Flag cifrada con public_key.pem
- /home/pasta/encrypted_ssh_key.bin: Clave SSH cifrada con la flag como contraseña

Comandos que puedes usar:
- cd
- ls
- cat
- ssh
- base64

¿Puedes factorizar la clave RSA para recuperar la flag para descifrar la clave ssh y acceder al servidor queso?

Pista: Utiliza la biblioteca de factorización sagemath y cryptography para obtener la clave privada.

Pista: Comandos utilizados para cifrar la clave SSH:
    openssl enc -aes-256-cbc -salt -in "$SSH_KEY" -out "$ENCRYPTED_SSH_KEY" -pass "pass:$FLAG_CONTENT"
    openssl pkeyutl -encrypt -pubin -inkey "$PUBLIC_KEY" -in "$FLAG_FILE" -out "$ENCRYPTED_FLAG"

Pista: Recuerda que los archivos cifrados estan en datos binarios, cat es para texto utiliza base64 para medios que solo permiten texto.

