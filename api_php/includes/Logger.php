<?php
// api_php/includes/Logger.php

require_once __DIR__ . '/../config/Config.php';

class Logger {
    const DEBUG = 0;
    const INFO = 1;
    const WARNING = 2;
    const ERROR = 3;
    const CRITICAL = 4;
    
    private static $logLevels = [
        self::DEBUG => 'DEBUG',
        self::INFO => 'INFO',
        self::WARNING => 'WARNING',
        self::ERROR => 'ERROR',
        self::CRITICAL => 'CRITICAL'
    ];
    
    private static $minLevel = self::INFO;
    private static $config = null;
    
    private static function init() {
        if (self::$config === null) {
            self::$config = Config::getInstance();
            
            $configLevel = strtoupper(self::$config->getLogLevel());
            switch ($configLevel) {
                case 'DEBUG':
                    self::$minLevel = self::DEBUG;
                    break;
                case 'INFO':
                    self::$minLevel = self::INFO;
                    break;
                case 'WARNING':
                    self::$minLevel = self::WARNING;
                    break;
                case 'ERROR':
                    self::$minLevel = self::ERROR;
                    break;
                case 'CRITICAL':
                    self::$minLevel = self::CRITICAL;
                    break;
            }
        }
    }
    
    private static function log($level, $message, $context = []) {
        self::init();
        
        if ($level < self::$minLevel) {
            return;
        }
        
        $timestamp = date('Y-m-d H:i:s');
        $levelName = self::$logLevels[$level];
        $contextStr = !empty($context) ? ' Context: ' . json_encode($context) : '';
        $logMessage = "[$timestamp] $levelName: $message$contextStr" . PHP_EOL;
        
        // Log to file
        $logFile = __DIR__ . '/../' . self::$config->getLogFile();
        $logDir = dirname($logFile);
        
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }
        
        file_put_contents($logFile, $logMessage, FILE_APPEND | LOCK_EX);
        
        // Also log to error_log if it's an error or critical
        if ($level >= self::ERROR) {
            error_log($logMessage);
        }
        
        // In development, also output to stdout for debugging
        if (self::$config->isDevelopment() && $level >= self::WARNING) {
            echo $logMessage;
        }
    }
    
    public static function debug($message, $context = []) {
        self::log(self::DEBUG, $message, $context);
    }
    
    public static function info($message, $context = []) {
        self::log(self::INFO, $message, $context);
    }
    
    public static function warning($message, $context = []) {
        self::log(self::WARNING, $message, $context);
    }
    
    public static function error($message, $context = []) {
        self::log(self::ERROR, $message, $context);
    }
    
    public static function critical($message, $context = []) {
        self::log(self::CRITICAL, $message, $context);
    }
    
    // Méthode pour logger les requêtes API
    public static function logRequest($method, $endpoint, $params = [], $responseCode = null) {
        $message = "API Request: $method $endpoint";
        $context = [
            'method' => $method,
            'endpoint' => $endpoint,
            'params' => $params,
            'response_code' => $responseCode,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
        ];
        
        if ($responseCode && $responseCode >= 400) {
            self::warning($message, $context);
        } else {
            self::info($message, $context);
        }
    }
    
    // Méthode pour logger les erreurs de base de données
    public static function logDatabaseError($operation, $error, $query = null) {
        $message = "Database Error: $operation failed";
        $context = [
            'operation' => $operation,
            'error' => $error,
            'query' => $query
        ];
        
        self::error($message, $context);
    }
    
    // Méthode pour logger les tentatives de sécurité
    public static function logSecurityEvent($event, $details = []) {
        $message = "Security Event: $event";
        $context = array_merge($details, [
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
            'timestamp' => time()
        ]);
        
        self::warning($message, $context);
    }
}
?>
