<?php
// api_php/config/Config.php

class Config {
    private static $instance = null;
    private $config = [];
    
    private function __construct() {
        $this->loadEnvironmentVariables();
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    private function loadEnvironmentVariables() {
        $envFile = __DIR__ . '/../.env';
        
        if (file_exists($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                if (strpos(trim($line), '#') === 0) {
                    continue; // Skip comments
                }
                
                if (strpos($line, '=') !== false) {
                    list($key, $value) = explode('=', $line, 2);
                    $key = trim($key);
                    $value = trim($value);
                    
                    // Remove quotes if present
                    if (preg_match('/^"(.*)"$/', $value, $matches)) {
                        $value = $matches[1];
                    } elseif (preg_match("/^'(.*)'$/", $value, $matches)) {
                        $value = $matches[1];
                    }
                    
                    $this->config[$key] = $value;
                    
                    // Also set as environment variable if not already set
                    if (!isset($_ENV[$key])) {
                        $_ENV[$key] = $value;
                        putenv("$key=$value");
                    }
                }
            }
        }
        
        // Fallback to system environment variables
        foreach ($_ENV as $key => $value) {
            if (!isset($this->config[$key])) {
                $this->config[$key] = $value;
            }
        }
    }
    
    public function get($key, $default = null) {
        return isset($this->config[$key]) ? $this->config[$key] : $default;
    }
    
    public function getDbHost() {
        return $this->get('DB_HOST', 'localhost');
    }
    
    public function getDbName() {
        return $this->get('DB_NAME', 'ai_one_db');
    }
    
    public function getDbUsername() {
        return $this->get('DB_USERNAME', 'root');
    }
    
    public function getDbPassword() {
        return $this->get('DB_PASSWORD', '');
    }
    
    public function getEnvironment() {
        return $this->get('ENVIRONMENT', 'production');
    }
    
    public function isDebug() {
        return filter_var($this->get('DEBUG', 'false'), FILTER_VALIDATE_BOOLEAN);
    }
    
    public function isDevelopment() {
        return $this->getEnvironment() === 'development';
    }
    
    public function isProduction() {
        return $this->getEnvironment() === 'production';
    }
    
    public function getRateLimit() {
        return (int) $this->get('API_RATE_LIMIT', 60);
    }
    
    public function getTokenSecret() {
        return $this->get('API_TOKEN_SECRET');
    }
    
    public function getLogLevel() {
        return $this->get('LOG_LEVEL', 'info');
    }
    
    public function getLogFile() {
        return $this->get('LOG_FILE', 'logs/api.log');
    }
    
    public function getEncryptionKey() {
        return $this->get('ENCRYPTION_KEY');
    }
}
?>
