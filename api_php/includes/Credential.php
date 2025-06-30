<?php
// api_php/includes/Credential.php

class Credential {
    private $conn;
    private $table_name = "credentials";

    // Propriétés de l'objet
    public $id;
    public $nom_site_compte;
    public $nom_utilisateur_email;
    public $mot_de_passe_chiffre; // Stockera le HASH du mot de passe
    public $autres_infos_chiffre; // Stockera les données EN CLAIR
    public $categorie;
    public $created_at;
    public $updated_at;

    // Constructeur
    public function __construct($db) {
        $this->conn = $db;
        // Plus besoin de gérer la clé de chiffrement ici puisque nous ne chiffrons plus les données.
    }

    // Read all credentials (maintenu sans mot de passe et autres infos pour la liste)
    public function read() {
        $query = "SELECT id, nom_site_compte, nom_utilisateur_email, categorie, created_at, updated_at
                  FROM " . $this->table_name . " ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt;
    }

    // Read single credential (inclut toutes les infos, mais 'autres_infos_chiffre' sera en clair)
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
            $this->mot_de_passe_chiffre = $row['mot_de_passe_chiffre']; // Ceci est le hash
            $this->autres_infos_chiffre = $row['autres_infos_chiffre']; // Maintenant en clair, pas de déchiffrement
            $this->categorie = $row['categorie'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            return true;
        }
        return false;
    }

    // Create credential
    public function create() {
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

        // Hachage du mot de passe (toujours utiliser password_hash pour la sécurité)
        $hashed_password = password_hash($this->mot_de_passe_chiffre, PASSWORD_DEFAULT);
        
        // Les autres informations sont stockées en clair
        $plain_other_info = $this->autres_infos_chiffre; // Pas de chiffrement

        // Bind values
        $stmt->bindParam(":nom_site_compte", $this->nom_site_compte);
        $stmt->bindParam(":nom_utilisateur_email", $this->nom_utilisateur_email);
        $stmt->bindParam(":mot_de_passe_chiffre", $hashed_password); // Stocke le HASH
        $stmt->bindParam(":autres_infos_chiffre", $plain_other_info); // Stocke les données en clair
        $stmt->bindParam(":categorie", $this->categorie);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Update credential
    public function update() {
        $query_parts = [];
        $query_parts[] = "nom_site_compte=:nom_site_compte";
        $query_parts[] = "nom_utilisateur_email=:nom_utilisateur_email";

        // Mettre à jour le mot de passe seulement si un nouveau est fourni (hacher si fourni)
        if (!empty($this->mot_de_passe_chiffre)) {
            $query_parts[] = "mot_de_passe_chiffre=:mot_de_passe_chiffre";
        }
        
        $query_parts[] = "autres_infos_chiffre=:autres_infos_chiffre"; // Mettre à jour en clair
        $query_parts[] = "categorie=:categorie";
        $query_parts[] = "updated_at=CURRENT_TIMESTAMP";

        $query = "UPDATE " . $this->table_name . " SET " . implode(", ", $query_parts) . " WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        // Sanitize and process data
        $this->nom_site_compte = htmlspecialchars(strip_tags($this->nom_site_compte));
        $this->nom_utilisateur_email = htmlspecialchars(strip_tags($this->nom_utilisateur_email));
        $this->categorie = htmlspecialchars(strip_tags($this->categorie));
        $this->id = htmlspecialchars(strip_tags($this->id));

        $plain_other_info = $this->autres_infos_chiffre; // Pas de chiffrement

        // Bind values
        $stmt->bindParam(":nom_site_compte", $this->nom_site_compte);
        $stmt->bindParam(":nom_utilisateur_email", $this->nom_utilisateur_email);
        $stmt->bindParam(":autres_infos_chiffre", $plain_other_info); // Stocke les données en clair
        $stmt->bindParam(":categorie", $this->categorie);
        $stmt->bindParam(":id", $this->id);

        // Bind hashed password only if it's being updated
        if (!empty($this->mot_de_passe_chiffre)) {
            $hashed_password = password_hash($this->mot_de_passe_chiffre, PASSWORD_DEFAULT);
            $stmt->bindParam(":mot_de_passe_chiffre", $hashed_password);
        }

        if ($stmt->execute()) {
            return true;
        }
        return false;
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