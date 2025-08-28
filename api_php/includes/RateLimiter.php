<?php
// api_php/includes/RateLimiter.php

require_once __DIR__ . '/../config/Config.php';
require_once __DIR__ . '/Logger.php';

class RateLimiter {
    private $config;
    private $storageFile;
    
    public function __construct() {
        $this->config = Config::getInstance();
        $this->storageFile = __DIR__ . '/../logs/rate_limits.json';
        
        // Créer le fichier s'il n'existe pas
        if (!file_exists($this->storageFile)) {
            $dir = dirname($this->storageFile);
            if (!is_dir($dir)) {
                mkdir($dir, 0755, true);
            }
            file_put_contents($this->storageFile, json_encode([]));
        }
    }
    
    /**
     * Vérifie si une IP a dépassé la limite de requêtes
     */
    public function isRateLimited($ip = null, $limit = null, $windowSize = 3600) {
        if ($ip === null) {
            $ip = $this->getClientIP();
        }
        
        if ($limit === null) {
            $limit = $this->config->getRateLimit();
        }
        
        $data = $this->loadRateData();
        $currentTime = time();
        
        // Nettoyer les anciennes entrées
        $this->cleanOldEntries($data, $currentTime, $windowSize);
        
        // Vérifier la limite pour cette IP
        if (!isset($data[$ip])) {
            $data[$ip] = [];
        }
        
        // Compter les requêtes dans la fenêtre de temps
        $requestsInWindow = 0;
        foreach ($data[$ip] as $timestamp) {
            if ($timestamp > ($currentTime - $windowSize)) {
                $requestsInWindow++;
            }
        }
        
        // Ajouter la requête actuelle
        $data[$ip][] = $currentTime;
        
        // Sauvegarder les données
        $this->saveRateData($data);
        
        if ($requestsInWindow >= $limit) {
            Logger::logSecurityEvent('Rate limit exceeded', [
                'ip' => $ip,
                'requests_in_window' => $requestsInWindow,
                'limit' => $limit,
                'window_size' => $windowSize
            ]);
            return true;
        }
        
        return false;
    }
    
    /**
     * Obtient l'adresse IP réelle du client
     */
    private function getClientIP() {
        $ipKeys = ['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_X_FORWARDED', 'HTTP_X_CLUSTER_CLIENT_IP', 'HTTP_FORWARDED_FOR', 'HTTP_FORWARDED', 'REMOTE_ADDR'];
        
        foreach ($ipKeys as $key) {
            if (array_key_exists($key, $_SERVER) === true) {
                foreach (explode(',', $_SERVER[$key]) as $ip) {
                    $ip = trim($ip);
                    
                    if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false) {
                        return $ip;
                    }
                }
            }
        }
        
        return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    }
    
    /**
     * Charge les données de rate limiting
     */
    private function loadRateData() {
        $content = file_get_contents($this->storageFile);
        if ($content === false) {
            return [];
        }
        
        $data = json_decode($content, true);
        return is_array($data) ? $data : [];
    }
    
    /**
     * Sauvegarde les données de rate limiting
     */
    private function saveRateData($data) {
        file_put_contents($this->storageFile, json_encode($data), LOCK_EX);
    }
    
    /**
     * Nettoie les anciennes entrées
     */
    private function cleanOldEntries(&$data, $currentTime, $windowSize) {
        foreach ($data as $ip => $timestamps) {
            $data[$ip] = array_filter($timestamps, function($timestamp) use ($currentTime, $windowSize) {
                return $timestamp > ($currentTime - $windowSize);
            });
            
            // Supprimer les IPs sans requêtes récentes
            if (empty($data[$ip])) {
                unset($data[$ip]);
            }
        }
    }
    
    /**
     * Bloque temporairement une IP
     */
    public function blockIP($ip, $duration = 3600) {
        $blockFile = __DIR__ . '/../logs/blocked_ips.json';
        
        $blockedIPs = [];
        if (file_exists($blockFile)) {
            $content = file_get_contents($blockFile);
            $blockedIPs = json_decode($content, true) ?: [];
        }
        
        $blockedIPs[$ip] = time() + $duration;
        file_put_contents($blockFile, json_encode($blockedIPs), LOCK_EX);
        
        Logger::logSecurityEvent('IP blocked', [
            'ip' => $ip,
            'duration' => $duration,
            'until' => date('Y-m-d H:i:s', time() + $duration)
        ]);
    }
    
    /**
     * Vérifie si une IP est bloquée
     */
    public function isBlocked($ip = null) {
        if ($ip === null) {
            $ip = $this->getClientIP();
        }
        
        $blockFile = __DIR__ . '/../logs/blocked_ips.json';
        
        if (!file_exists($blockFile)) {
            return false;
        }
        
        $content = file_get_contents($blockFile);
        $blockedIPs = json_decode($content, true) ?: [];
        
        if (isset($blockedIPs[$ip])) {
            if ($blockedIPs[$ip] > time()) {
                return true; // Encore bloqué
            } else {
                // Débloquer l'IP
                unset($blockedIPs[$ip]);
                file_put_contents($blockFile, json_encode($blockedIPs), LOCK_EX);
            }
        }
        
        return false;
    }
    
    /**
     * Réponse HTTP pour rate limiting
     */
    public function sendRateLimitResponse($retryAfter = 3600) {
        http_response_code(429);
        header('Retry-After: ' . $retryAfter);
        header('Content-Type: application/json');
        
        echo json_encode([
            'error' => true,
            'message' => 'Too many requests. Please try again later.',
            'code' => 'RATE_LIMIT_EXCEEDED',
            'retry_after' => $retryAfter
        ]);
        
        exit();
    }
    
    /**
     * Réponse HTTP pour IP bloquée
     */
    public function sendBlockedResponse() {
        http_response_code(403);
        header('Content-Type: application/json');
        
        echo json_encode([
            'error' => true,
            'message' => 'Access forbidden. Your IP has been temporarily blocked.',
            'code' => 'IP_BLOCKED'
        ]);
        
        exit();
    }
    
    /**
     * Middleware à utiliser au début de chaque endpoint API
     */
    public function checkRateLimit($strictLimit = null) {
        $ip = $this->getClientIP();
        
        // Vérifier si l'IP est bloquée
        if ($this->isBlocked($ip)) {
            $this->sendBlockedResponse();
        }
        
        // Vérifier la limite de requêtes
        if ($this->isRateLimited($ip, $strictLimit)) {
            // Bloquer automatiquement après 3 dépassements consécutifs
            static $violations = [];
            if (!isset($violations[$ip])) {
                $violations[$ip] = 0;
            }
            $violations[$ip]++;
            
            if ($violations[$ip] >= 3) {
                $this->blockIP($ip, 7200); // Bloquer pour 2 heures
                $this->sendBlockedResponse();
            }
            
            $this->sendRateLimitResponse();
        }
    }
}
?>
