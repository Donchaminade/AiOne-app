import os
import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import padding
from dotenv import load_dotenv
from typing import Optional # <<<-- C'EST LA LIGNE QUI MANQUAIT !

# Charger les variables d'environnement depuis le fichier .env
load_dotenv()

# Récupérer la clé de chiffrement depuis les variables d'environnement
# La clé doit être décodée de base64 pour être utilisée
SECRET_ENCRYPTION_KEY_BASE64 = os.getenv("SECRET_ENCRYPTION_KEY")
if SECRET_ENCRYPTION_KEY_BASE64 is None:
    raise ValueError("SECRET_ENCRYPTION_KEY non définie dans .env. Assurez-vous qu'elle est définie et générée.")
SECRET_ENCRYPTION_KEY = base64.urlsafe_b64decode(SECRET_ENCRYPTION_KEY_BASE64)

# Vérifier que la clé a la bonne taille pour AES-256 (32 octets)
if len(SECRET_ENCRYPTION_KEY) != 32:
    raise ValueError("SECRET_ENCRYPTION_KEY doit être de 32 octets (256 bits) après décodage Base64.")

def encrypt_aes(plaintext: str) -> str:
    """Chiffre une chaîne de caractères en utilisant AES-256 GCM."""
    if not plaintext:
        return ""

    padder = padding.PKCS7(algorithms.AES.block_size).padder()
    padded_data = padder.update(plaintext.encode('utf-8')) + padder.finalize()

    # Générer un IV (Initialization Vector) et un GCM tag aléatoires pour chaque chiffrement
    iv = os.urandom(16)  # IV pour AES en mode GCM, 12 octets sont recommandés mais 16 est courant
    cipher = Cipher(algorithms.AES(SECRET_ENCRYPTION_KEY), modes.GCM(iv), backend=default_backend())
    encryptor = cipher.encryptor()

    ciphertext = encryptor.update(padded_data) + encryptor.finalize()
    tag = encryptor.tag

    # Retourne IV, ciphertext et tag encodés en base64 (séparés par un délimiteur)
    return base64.urlsafe_b64encode(iv + ciphertext + tag).decode('utf-8')

def decrypt_aes(encrypted_text: str) -> Optional[str]:
    """Déchiffre une chaîne de caractères chiffrée en utilisant AES-256 GCM."""
    if not encrypted_text:
        return ""

    try:
        decoded_data = base64.urlsafe_b64decode(encrypted_text)
        iv = decoded_data[:16] # Récupère l'IV (16 premiers octets)
        ciphertext_with_tag = decoded_data[16:]

        # Le tag GCM est les 16 derniers octets du ciphertext_with_tag
        tag = ciphertext_with_tag[-16:]
        ciphertext = ciphertext_with_tag[:-16]

        cipher = Cipher(algorithms.AES(SECRET_ENCRYPTION_KEY), modes.GCM(iv, tag), backend=default_backend())
        decryptor = cipher.decryptor()

        decrypted_padded_data = decryptor.update(ciphertext) + decryptor.finalize()

        unpadder = padding.PKCS7(algorithms.AES.block_size).unpadder()
        plaintext = unpadder.update(decrypted_padded_data) + unpadder.finalize()

        return plaintext.decode('utf-8')
    except Exception as e:
        print(f"Erreur de déchiffrement: {e}")
        return None # Ou lever une exception appropriée