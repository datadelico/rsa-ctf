import random
import math
import os
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateNumbers, RSAPublicNumbers
from cryptography.hazmat.backends import default_backend

def is_prime(n, k=5):
    """Test de primalidad Miller-Rabin"""
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0:
        return False
    
    r, s = 0, n - 1
    while s % 2 == 0:
        r += 1
        s //= 2
    
    for _ in range(k):
        a = random.randrange(2, n - 1)
        x = pow(a, s, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True

def generate_prime(bits):
    """Genera un número primo aleatorio de bits específicos"""
    while True:
        p = random.getrandbits(bits)
        # Asegurarnos de que tenga exactamente los bits especificados
        p |= (1 << bits - 1) | 1  # Forzar que el bit MSB sea 1 y que sea impar
        if is_prime(p):
            return p

def generate_weak_rsa(bits=256, output_dir="docker/pasta-server/keys"):
    """Genera claves RSA débiles de tamaño específico"""
    # Generamos dos primos p y q de bits/2 bits cada uno
    prime_size = bits // 2
    p = generate_prime(prime_size)
    q = generate_prime(prime_size)
    
    n = p * q
    phi = (p - 1) * (q - 1)
    
    # Elegimos un e típico
    e = 65537
    
    # Calculamos d (inverso multiplicativo de e mod phi)
    def egcd(a, b):
        if a == 0:
            return (b, 0, 1)
        else:
            g, x, y = egcd(b % a, a)
            return (g, y - (b // a) * x, x)
    
    def modinv(a, m):
        g, x, y = egcd(a, m)
        if g != 1:
            raise Exception('No existe inverso multiplicativo')
        else:
            return x % m
    
    d = modinv(e, phi)
    
    # Convertimos a claves criptográficas usando la biblioteca cryptography
    dmp1 = d % (p - 1)
    dmq1 = d % (q - 1)
    iqmp = modinv(q, p)
    
    private_numbers = RSAPrivateNumbers(
        p=p, q=q, d=d,
        dmp1=dmp1, dmq1=dmq1, iqmp=iqmp,
        public_numbers=RSAPublicNumbers(e=e, n=n)
    )
    
    private_key = private_numbers.private_key(default_backend())
    public_key = private_key.public_key()
    
    # Serializar las claves
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    public_pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    
    # Crear el directorio si no existe
    os.makedirs(output_dir, exist_ok=True)
    
    # Guardar en archivos en el directorio especificado
    private_key_path = os.path.join(output_dir, "private_key.pem")
    public_key_path = os.path.join(output_dir, "public_key.pem")
    
    with open(private_key_path, "wb") as f:
        f.write(private_pem)
    
    with open(public_key_path, "wb") as f:
        f.write(public_pem)
    
    print(f"Módulo RSA de {bits} bits generado correctamente")
    print(f"Claves guardadas en el directorio {output_dir}")
    return private_pem, public_pem

if __name__ == "__main__":
    private_key, public_key = generate_weak_rsa()
    print("Claves RSA generadas correctamente.")
    print("Clave privada guardada en 'docker/pasta-server/keys/private_key.pem'.")
    print("Clave pública guardada en 'docker/pasta-server/keys/public_key.pem'.")