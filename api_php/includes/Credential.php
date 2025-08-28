<?php
// api_php/includes/Credential.php

require_once __DIR__ . '/Encryption.php';
require_once __DIR__ . '/Logger.php';

class Credential {
    private $conn;
    private $table_name = "credentials";
    private $encryption;

    // Propriétés de l'objet
    public $id;
    public $nom_site_compte;
    public $nom_utilisateur_email;
    public $mot_de_passe_chiffre; // Stockera le HASH du mot de passe
    public $autres_infos_chiffre; // Stockera les données CHIFFRÉES
    public $categorie;
    public $created_at;
    public $updated_at;

    // Constructeur
    public function __construct($db) {
        $this->conn = $db;
        try {
            $this->encryption = new Encryption();
        } catch (Exception $e) {
            Logger::critical('Failed to initialize encryption for Credential class', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    // Read all credentials avec pagination (sans données sensibles dans la liste)
    public function read($page = 1, $limit = 10, $search = '', $orderBy = 'created_at', $orderDir = 'DESC') {
        $offset = ($page - 1) * $limit;
        
        // Base query
        $query = "SELECT id, nom_site_compte, nom_utilisateur_email, categorie, created_at, updated_at FROM " . $this->table_name;
        
        // Add search condition
        $searchCondition = '';
        if (!empty($search)) {
            $searchCondition = " WHERE (nom_site_compte LIKE :search OR nom_utilisateur_email LIKE :search OR categorie LIKE :search)";
        }
        
        // Validate order by field
        $allowedOrderFields = ['nom_site_compte', 'nom_utilisateur_email', 'categorie', 'created_at', 'updated_at'];
        if (!in_array($orderBy, $allowedOrderFields)) {
            $orderBy = 'created_at';
        }
        
        // Validate order direction
        $orderDir = strtoupper($orderDir);
        if (!in_array($orderDir, ['ASC', 'DESC'])) {
            $orderDir = 'DESC';
        }
        
        $query .= $searchCondition . " ORDER BY $orderBy $orderDir LIMIT :limit OFFSET :offset";
        
        $stmt = $this->conn->prepare($query);
        
        // Bind search parameter if needed
        if (!empty($search)) {
            $searchParam = "%$search%";
            $stmt->bindParam(':search', $searchParam);
        }
        
        // Bind pagination parameters
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        
        $stmt->execute();
        return $stmt;
    }
    
    // Count total credentials pour pagination
    public function count($search = '') {
        $query = "SELECT COUNT(*) as total FROM " . $this->table_name;
        
        if (!empty($search)) {
            $query .= " WHERE (nom_site_compte LIKE :search OR nom_utilisateur_email LIKE :search OR categorie LIKE :search)";
        }
        
        $stmt = $this->conn->prepare($query);
        
        if (!empty($search)) {
            $searchParam = "%$search%";
            $stmt->bindParam(':search', $searchParam);
        }
        
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return (int) $row['total'];
    }

    // Read single credential avec déchiffrement des données sensibles
    public function readOne() {
        $query = "SELECT id, nom_site_compte, nom_utilisateur_email, mot_de_passe_chiffre, autres_infos_chiffre, categorie, created_at, updated_at
                  FROM " . $this->table_name . " WHERE id = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            $this->nom_site_compte = $row['nom_site_compte'];
            $this->nom_utilisateur_email = $row['nom_utilisateur_email'];
            $this->mot_de_passe_chiffre = $row['mot_de_passe_chiffre']; // Hash - ne pas déchiffrer
            
            // Déchiffrer les autres informations si elles existent
            if (!empty($row['autres_infos_chiffre'])) {
                try {
                    $this->autres_infos_chiffre = $this->encryption->decrypt($row['autres_infos_chiffre']);
                    Logger::debug('Successfully decrypted credential additional info', ['credential_id' => $this->id]);
                } catch (Exception $e) {
                    Logger::error('Failed to decrypt credential additional info', [
                        'credential_id' => $this->id,
                        'error' => $e->getMessage()
                    ]);
                    $this->autres_infos_chiffre = ''; // Défaut si déchiffrement échoue
                }
            } else {
                $this->autres_infos_chiffre = '';
            }
            
            $this->categorie = $row['categorie'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            return true;
        }
        return false;
    }

    // Create credential avec chiffrement sécurisé
    public function create() {
        try {
            $query = "INSERT INTO " . $this->table_name . " SET
                        nom_site_compte=:nom_site_compte,
                        nom_utilisateur_email=:nom_utilisateur_email,
                        mot_de_passe_chiffre=:mot_de_passe_chiffre,
                        autres_infos_chiffre=:autres_infos_chiffre,
                        categorie=:categorie";

            $stmt = $this->conn->prepare($query);

            // Sanitize and process data for storage
            $this->nom_site_compte = htmlspecialchars(strip_tags($this->nom_site_compte));
            $this->nom_utilisateur_email = htmlspecialchars(strip_tags($this->nom_utilisateur_email));
            $this->categorie = htmlspecialchars(strip_tags($this->categorie));

            // Hash du mot de passe avec Argon2ID (plus sécurisé)
            $hashed_password = $this->encryption->hashPassword($this->mot_de_passe_chiffre);
            
            // Chiffrement des autres informations sensibles
            $encrypted_other_info = '';
            if (!empty($this->autres_infos_chiffre)) {
                $encrypted_other_info = $this->encryption->encrypt($this->autres_infos_chiffre);
            }

            // Bind values
            $stmt->bindParam(":nom_site_compte", $this->nom_site_compte);
            $stmt->bindParam(":nom_utilisateur_email", $this->nom_utilisateur_email);
            $stmt->bindParam(":mot_de_passe_chiffre", $hashed_password);
            $stmt->bindParam(":autres_infos_chiffre", $encrypted_other_info);
            $stmt->bindParam(":categorie", $this->categorie);

            if ($stmt->execute()) {
                Logger::info('Credential created successfully', [
                    'nom_site_compte' => $this->nom_site_compte,
                    'nom_utilisateur_email' => $this->nom_utilisateur_email
                ]);
                return true;
            }
            
            Logger::error('Failed to execute credential creation query');
            return false;
            
        } catch (Exception $e) {
            Logger::error('Error creating credential', ['error' => $e->getMessage()]);
            return false;
        }
    }

    // Update credential avec chiffrement sécurisé
    public function update() {
        try {
            $query_parts = [];
            $query_parts[] = "nom_site_compte=:nom_site_compte";
            $query_parts[] = "nom_utilisateur_email=:nom_utilisateur_email";

            // Mettre à jour le mot de passe seulement si un nouveau est fourni
            if (!empty($this->mot_de_passe_chiffre)) {
                $query_parts[] = "mot_de_passe_chiffre=:mot_de_passe_chiffre";
            }
            
            $query_parts[] = "autres_infos_chiffre=:autres_infos_chiffre";
            $query_parts[] = "categorie=:categorie";
            $query_parts[] = "updated_at=CURRENT_TIMESTAMP";

            $query = "UPDATE " . $this->table_name . " SET " . implode(", ", $query_parts) . " WHERE id = :id";

            $stmt = $this->conn->prepare($query);

            // Sanitize and process data
            $this->nom_site_compte = htmlspecialchars(strip_tags($this->nom_site_compte));
            $this->nom_utilisateur_email = htmlspecialchars(strip_tags($this->nom_utilisateur_email));
            $this->categorie = htmlspecialchars(strip_tags($this->categorie));
            $this->id = htmlspecialchars(strip_tags($this->id));

            // Chiffrer les autres informations
            $encrypted_other_info = '';
            if (!empty($this->autres_infos_chiffre)) {
                $encrypted_other_info = $this->encryption->encrypt($this->autres_infos_chiffre);
            }

            // Bind values
            $stmt->bindParam(":nom_site_compte", $this->nom_site_compte);
            $stmt->bindParam(":nom_utilisateur_email", $this->nom_utilisateur_email);
            $stmt->bindParam(":autres_infos_chiffre", $encrypted_other_info);
            $stmt->bindParam(":categorie", $this->categorie);
            $stmt->bindParam(":id", $this->id);

            // Hash du mot de passe si fourni
            if (!empty($this->mot_de_passe_chiffre)) {
                $hashed_password = $this->encryption->hashPassword($this->mot_de_passe_chiffre);
                $stmt->bindParam(":mot_de_passe_chiffre", $hashed_password);
            }

            if ($stmt->execute()) {
                Logger::info('Credential updated successfully', ['credential_id' => $this->id]);
                return true;
            }
            
            Logger::error('Failed to execute credential update query', ['credential_id' => $this->id]);
            return false;
            
        } catch (Exception $e) {
            Logger::error('Error updating credential', [
                'credential_id' => $this->id,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    // Delete credential
    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
        $stmt = $this->conn->prepare($query);
        $this->id = htmlspecialchars(strip_tags($this->id));
        $stmt->bindParam(1, $this->id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Méthode pour vérifier un mot de passe (haché)
    public function verifyPassword($plain_password) {
        $query = "SELECT mot_de_passe_chiffre FROM " . $this->table_name . " WHERE id = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row && password_verify($plain_password, $row['mot_de_passe_chiffre'])) {
            return true;
        }
        return false;
    }
}
?>