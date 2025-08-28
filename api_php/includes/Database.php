<?php
// api_php/includes/Database.php

require_once __DIR__ . '/../config/Config.php';
require_once __DIR__ . '/Logger.php';

class Database {
    private $conn;
    private $config;
    private static $instance = null;

    private function __construct() {
        $this->config = Config::getInstance();
    }

    // Singleton pattern pour éviter les connexions multiples
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    // Get the database connection
    public function getConnection() {
        if ($this->conn !== null) {
            return $this->conn;
        }

        try {
            $dsn = "mysql:host=" . $this->config->getDbHost() . ";dbname=" . $this->config->getDbName() . ";charset=utf8mb4";
            
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
            ];
            
            $this->conn = new PDO($dsn, $this->config->getDbUsername(), $this->config->getDbPassword(), $options);
            
            Logger::info('Database connection established successfully');
            
        } catch(PDOException $exception) {
            Logger::critical('Database connection failed', [
                'error' => $exception->getMessage(),
                'host' => $this->config->getDbHost(),
                'database' => $this->config->getDbName()
            ]);
            
            // Différencier les messages d'erreur selon l'environnement
            if ($this->config->isDevelopment()) {
                $errorMessage = "Database connection error: " . $exception->getMessage();
            } else {
                $errorMessage = "Database connection error. Please try again later.";
            }
            
            http_response_code(503);
            echo json_encode([
                "error" => true,
                "message" => $errorMessage,
                "code" => "DB_CONNECTION_FAILED"
            ]);
            exit();
        }

        return $this->conn;
    }

    // Méthode pour tester la connexion
    public function testConnection() {
        try {
            $conn = $this->getConnection();
            $conn->query('SELECT 1');
            return true;
        } catch (Exception $e) {
            Logger::error('Database connection test failed', ['error' => $e->getMessage()]);
            return false;
        }
    }

    // Méthode pour fermer la connexion
    public function closeConnection() {
        $this->conn = null;
        Logger::debug('Database connection closed');
    }

    // Méthode pour commencer une transaction
    public function beginTransaction() {
        try {
            $this->getConnection()->beginTransaction();
            Logger::debug('Database transaction started');
            return true;
        } catch (PDOException $e) {
            Logger::error('Failed to start transaction', ['error' => $e->getMessage()]);
            return false;
        }
    }

    // Méthode pour valider une transaction
    public function commit() {
        try {
            $this->getConnection()->commit();
            Logger::debug('Database transaction committed');
            return true;
        } catch (PDOException $e) {
            Logger::error('Failed to commit transaction', ['error' => $e->getMessage()]);
            return false;
        }
    }

    // Méthode pour annuler une transaction
    public function rollback() {
        try {
            $this->getConnection()->rollback();
            Logger::debug('Database transaction rolled back');
            return true;
        } catch (PDOException $e) {
            Logger::error('Failed to rollback transaction', ['error' => $e->getMessage()]);
            return false;
        }
    }
}
?>