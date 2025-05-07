from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateNumbers, RSAPublicNumbers
from cryptography.hazmat.backends import default_backend
import sys

def extract_n_e_from_pem(public_key_file):
    """Extrae n y e desde una clave pública en formato PEM"""
    with open(public_key_file, 'rb') as f:
        public_key = serialization.load_pem_public_key(f.read(), default_backend())
    
    # Obtener n y e
    public_numbers = public_key.public_numbers()
    return public_numbers.n, public_numbers.e

def factor_rsa(n):
    """Factoriza n = p*q en números primos p y q usando SageMath"""
    try:
        # Usar SageMath directamente para factorizar
        from sage.all import factor
        factors = factor(n)
        
        # Extraer los factores primos p y q
        if len(factors) >= 2:
            # Convertir a enteros de Python
            p = int(factors[0][0])
            q = int(factors[1][0])
            return p, q
        else:
            raise ValueError(f"No se encontraron exactamente 2 factores: {factors}")
    
    except ImportError:
        raise ImportError("SageMath no está disponible. Instala SageMath o usa: sage -python crack_rsa.py")

def crack_rsa(public_key_file='public_key.pem'):
    """Rompe RSA débil y genera la clave privada usando SageMath"""
    print(f"Intentando romper la clave pública en {public_key_file}...")
    
    # Extraer n y e de la clave pública
    n, e = extract_n_e_from_pem(public_key_file)
    print(f"Módulo n = {n} ({n.bit_length()} bits)")
    print(f"Exponente e = {e}")
    
    # Factorizar n para obtener p y q usando SageMath
    print("Factorizando n con SageMath...")
    p, q = factor_rsa(n)
    print(f"Factores encontrados: p = {p}, q = {q}")
    
    # Calcular la clave privada
    phi = (p - 1) * (q - 1)
    d = pow(e, -1, phi)
    
    print(f"Clave privada d = {d}")
    
    # Calcular componentes adicionales
    dmp1 = d % (p - 1)
    dmq1 = d % (q - 1)
    iqmp = pow(q, -1, p)
    
    # Crear objeto de clave privada
    private_numbers = RSAPrivateNumbers(
        p=p, q=q, d=d,
        dmp1=dmp1, dmq1=dmq1, iqmp=iqmp,
        public_numbers=RSAPublicNumbers(e=e, n=n)
    )
    
    private_key = private_numbers.private_key(default_backend())
    
    # Serializar clave privada recuperada
    recovered_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    # Guardar clave privada recuperada
    with open("recovered_key.pem", "wb") as f:
        f.write(recovered_pem)
    
    # Verificar si existe la clave privada original para comparar
    try:
        with open("private_key.pem", "rb") as f:
            original_pem = f.read()
        
        # Extraer clave privada original para comparar d
        original_key = serialization.load_pem_private_key(
            original_pem, password=None, backend=default_backend()
        )
        original_d = original_key.private_numbers().d
        
        if original_d == d:
            print("¡Éxito! La clave privada recuperada coincide con la original.")
        else:
            print("La clave privada recuperada difiere de la original.")
            
    except FileNotFoundError:
        print("No se encontró la clave privada original para comparar.")
    
    print("Clave privada recuperada guardada en 'recovered_key.pem'")
    return private_key

if __name__ == "__main__":
    if len(sys.argv) > 1:
        public_key_file = sys.argv[1]
    else:
        public_key_file = 'public_key.pem'
        
    crack_rsa(public_key_file)