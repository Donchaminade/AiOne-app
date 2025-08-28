<?php
// api_php/includes/Encryption.php

require_once __DIR__ . '/../config/Config.php';
require_once __DIR__ . '/Logger.php';

class Encryption {
    private $key;
    private $cipher = 'AES-256-CBC';
    
    public function __construct() {
        $config = Config::getInstance();
        $this->key = $config->getEncryptionKey();
        
        if (empty($this->key)) {
            Logger::critical('Encryption key is not set in configuration');
            throw new Exception('Encryption key not configured');
        }
        
        // La clé doit faire exactement 32 caractères pour AES-256
        if (strlen($this->key) !== 32) {
            Logger::warning('Encryption key length is not optimal, padding/truncating to 32 chars');
            $this->key = str_pad(substr($this->key, 0, 32), 32, '0');
        }
    }
    
    /**
     * Chiffre une chaîne de caractères
     */
    public function encrypt($plaintext) {
        if (empty($plaintext)) {
            return '';
        }
        
        try {
            $ivlen = openssl_cipher_iv_length($this->cipher);
            $iv = openssl_random_pseudo_bytes($ivlen);
            $encrypted = openssl_encrypt($plaintext, $this->cipher, $this->key, 0, $iv);
            
            if ($encrypted === false) {
                Logger::error('Encryption failed', ['error' => openssl_error_string()]);
                throw new Exception('Encryption failed');
            }
            
            // On combine l'IV et les données chiffrées
            return base64_encode($iv . $encrypted);
            
        } catch (Exception $e) {
            Logger::error('Encryption process failed', ['error' => $e->getMessage()]);
            throw $e;
        }
    }
    
    /**
     * Déchiffre une chaîne de caractères
     */
    public function decrypt($ciphertext) {
        if (empty($ciphertext)) {
            return '';
        }
        
        try {
            $data = base64_decode($ciphertext);
            if ($data === false) {
                Logger::warning('Invalid base64 data for decryption');
                throw new Exception('Invalid encrypted data format');
            }
            
            $ivlen = openssl_cipher_iv_length($this->cipher);
            $iv = substr($data, 0, $ivlen);
            $encrypted = substr($data, $ivlen);
            
            $decrypted = openssl_decrypt($encrypted, $this->cipher, $this->key, 0, $iv);
            
            if ($decrypted === false) {
                Logger::error('Decryption failed', ['error' => openssl_error_string()]);
                throw new Exception('Decryption failed');
            }
            
            return $decrypted;
            
        } catch (Exception $e) {
            Logger::error('Decryption process failed', ['error' => $e->getMessage()]);
            throw $e;
        }
    }
    
    /**
     * Hash sécurisé pour les mots de passe
     */
    public function hashPassword($password) {
        return password_hash($password, PASSWORD_ARGON2ID, [
            'memory_cost' => 65536, // 64 MB
            'time_cost' => 4,       // 4 itérations
            'threads' => 3          // 3 threads
        ]);
    }
    
    /**
     * Vérification de mot de passe
     */
    public function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
    
    /**
     * Génère une clé de chiffrement sécurisée
     */
    public static function generateKey($length = 32) {
        return bin2hex(random_bytes($length / 2));
    }
    
    /**
     * Génère un token sécurisé
     */
    public static function generateToken($length = 32) {
        return bin2hex(random_bytes($length));
    }
}
?>
