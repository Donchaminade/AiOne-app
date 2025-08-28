<?php
// api_php/includes/Note.php

class Note {
    private $conn;
    private $table_name = "notes";

    public $id;
    public $titre;
    public $sous_titre;
    public $contenu;
    public $dossiers;
    public $tags_labels;
    public $created_at;
    public $updated_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function read($page = 1, $limit = 10, $search = '', $orderBy = 'created_at', $orderDir = 'DESC') {
        $offset = ($page - 1) * $limit;
        
        $query = "SELECT * FROM " . $this->table_name;
        
        $searchCondition = '';
        if (!empty($search)) {
            $searchCondition = " WHERE (titre LIKE :search OR sous_titre LIKE :search OR contenu LIKE :search OR dossiers LIKE :search)";
        }
        
        $allowedOrderFields = ['titre', 'sous_titre', 'created_at', 'updated_at'];
        if (!in_array($orderBy, $allowedOrderFields)) {
            $orderBy = 'created_at';
        }
        
        $orderDir = strtoupper($orderDir);
        if (!in_array($orderDir, ['ASC', 'DESC'])) {
            $orderDir = 'DESC';
        }
        
        $query .= $searchCondition . " ORDER BY $orderBy $orderDir LIMIT :limit OFFSET :offset";
        
        $stmt = $this->conn->prepare($query);
        
        if (!empty($search)) {
            $searchParam = "%$search%";
            $stmt->bindParam(':search', $searchParam);
        }
        
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        
        $stmt->execute();
        return $stmt;
    }
    
    public function count($search = '') {
        $query = "SELECT COUNT(*) as total FROM " . $this->table_name;
        
        if (!empty($search)) {
            $query .= " WHERE (titre LIKE :search OR sous_titre LIKE :search OR contenu LIKE :search OR dossiers LIKE :search)";
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

    public function readOne() {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            $this->titre = $row['titre'];
            $this->sous_titre = $row['sous_titre'];
            $this->contenu = $row['contenu'];
            $this->dossiers = $row['dossiers'];
            $this->tags_labels = $row['tags_labels'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            return true;
        }
        return false;
    }

    public function create() {
        $query = "INSERT INTO " . $this->table_name . " SET
                    titre=:titre, sous_titre=:sous_titre, contenu=:contenu,
                    dossiers=:dossiers, tags_labels=:tags_labels";

        $stmt = $this->conn->prepare($query);

        $this->titre = htmlspecialchars(strip_tags($this->titre));
        $this->sous_titre = htmlspecialchars(strip_tags($this->sous_titre));
        $this->contenu = htmlspecialchars(strip_tags($this->contenu));
        $this->dossiers = htmlspecialchars(strip_tags($this->dossiers));
        $this->tags_labels = htmlspecialchars(strip_tags($this->tags_labels));

        $stmt->bindParam(":titre", $this->titre);
        $stmt->bindParam(":sous_titre", $this->sous_titre);
        $stmt->bindParam(":contenu", $this->contenu);
        $stmt->bindParam(":dossiers", $this->dossiers);
        $stmt->bindParam(":tags_labels", $this->tags_labels);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function update() {
        $query = "UPDATE " . $this->table_name . " SET
                    titre=:titre,
                    sous_titre=:sous_titre,
                    contenu=:contenu,
                    dossiers=:dossiers,
                    tags_labels=:tags_labels,
                    updated_at=CURRENT_TIMESTAMP
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        $this->titre = htmlspecialchars(strip_tags($this->titre));
        $this->sous_titre = htmlspecialchars(strip_tags($this->sous_titre));
        $this->contenu = htmlspecialchars(strip_tags($this->contenu));
        $this->dossiers = htmlspecialchars(strip_tags($this->dossiers));
        $this->tags_labels = htmlspecialchars(strip_tags($this->tags_labels));
        $this->id = htmlspecialchars(strip_tags($this->id));

        $stmt->bindParam(":titre", $this->titre);
        $stmt->bindParam(":sous_titre", $this->sous_titre);
        $stmt->bindParam(":contenu", $this->contenu);
        $stmt->bindParam(":dossiers", $this->dossiers);
        $stmt->bindParam(":tags_labels", $this->tags_labels);
        $stmt->bindParam(":id", $this->id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

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
}
?>