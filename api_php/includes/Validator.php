<?php
// api_php/includes/Validator.php

class Validator {
    private $errors = [];
    
    public function getErrors() {
        return $this->errors;
    }
    
    public function hasErrors() {
        return !empty($this->errors);
    }
    
    public function clearErrors() {
        $this->errors = [];
    }
    
    public function addError($field, $message) {
        if (!isset($this->errors[$field])) {
            $this->errors[$field] = [];
        }
        $this->errors[$field][] = $message;
    }
    
    // Validation basique
    public function required($value, $field) {
        if (empty($value) && $value !== '0') {
            $this->addError($field, "Le champ '$field' est requis");
            return false;
        }
        return true;
    }
    
    public function minLength($value, $field, $minLength) {
        if (strlen($value) < $minLength) {
            $this->addError($field, "Le champ '$field' doit contenir au moins $minLength caractères");
            return false;
        }
        return true;
    }
    
    public function maxLength($value, $field, $maxLength) {
        if (strlen($value) > $maxLength) {
            $this->addError($field, "Le champ '$field' ne doit pas dépasser $maxLength caractères");
            return false;
        }
        return true;
    }
    
    // Validation d'email
    public function email($value, $field) {
        if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
            $this->addError($field, "Le champ '$field' doit contenir une adresse email valide");
            return false;
        }
        return true;
    }
    
    // Validation de numéro de téléphone
    public function phone($value, $field) {
        // Pattern flexible pour différents formats de téléphone
        $pattern = '/^[\+]?[0-9\s\-\(\)]{8,15}$/';
        if (!preg_match($pattern, $value)) {
            $this->addError($field, "Le champ '$field' doit contenir un numéro de téléphone valide");
            return false;
        }
        return true;
    }
    
    // Validation de date
    public function date($value, $field, $format = 'Y-m-d') {
        $dateObj = DateTime::createFromFormat($format, $value);
        if (!$dateObj || $dateObj->format($format) !== $value) {
            $this->addError($field, "Le champ '$field' doit contenir une date valide au format $format");
            return false;
        }
        return true;
    }
    
    // Validation de date et heure
    public function datetime($value, $field, $format = 'Y-m-d H:i:s') {
        return $this->date($value, $field, $format);
    }
    
    // Validation d'URL
    public function url($value, $field) {
        if (!filter_var($value, FILTER_VALIDATE_URL)) {
            $this->addError($field, "Le champ '$field' doit contenir une URL valide");
            return false;
        }
        return true;
    }
    
    // Validation numérique
    public function numeric($value, $field) {
        if (!is_numeric($value)) {
            $this->addError($field, "Le champ '$field' doit être numérique");
            return false;
        }
        return true;
    }
    
    public function integer($value, $field) {
        if (!filter_var($value, FILTER_VALIDATE_INT)) {
            $this->addError($field, "Le champ '$field' doit être un nombre entier");
            return false;
        }
        return true;
    }
    
    // Validation d'énumération
    public function inArray($value, $field, $allowedValues) {
        if (!in_array($value, $allowedValues)) {
            $allowed = implode(', ', $allowedValues);
            $this->addError($field, "Le champ '$field' doit être une des valeurs suivantes: $allowed");
            return false;
        }
        return true;
    }
    
    // Validation de mot de passe
    public function password($value, $field, $minLength = 8) {
        if (!$this->minLength($value, $field, $minLength)) {
            return false;
        }
        
        // Au moins une lettre majuscule, une minuscule et un chiffre
        if (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/', $value)) {
            $this->addError($field, "Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre");
            return false;
        }
        
        return true;
    }
    
    // Méthodes spécifiques pour chaque modèle
    public function validateContact($data) {
        $this->clearErrors();
        
        // Champs requis
        if (!isset($data->nom_complet) || !$this->required($data->nom_complet, 'nom_complet')) {
            return false;
        }
        if (!isset($data->adresse_email) || !$this->required($data->adresse_email, 'adresse_email')) {
            return false;
        }
        
        // Validation du nom
        $this->minLength($data->nom_complet, 'nom_complet', 2);
        $this->maxLength($data->nom_complet, 'nom_complet', 100);
        
        // Validation de l'email
        $this->email($data->adresse_email, 'adresse_email');
        
        // Validation optionnelle du téléphone
        if (!empty($data->numero_telephone)) {
            $this->phone($data->numero_telephone, 'numero_telephone');
        }
        
        // Validation de la date de naissance
        if (!empty($data->date_naissance)) {
            $this->date($data->date_naissance, 'date_naissance');
        }
        
        // Validation des autres champs
        if (!empty($data->profession)) {
            $this->maxLength($data->profession, 'profession', 100);
        }
        if (!empty($data->entreprise_organisation)) {
            $this->maxLength($data->entreprise_organisation, 'entreprise_organisation', 100);
        }
        if (!empty($data->adresse)) {
            $this->maxLength($data->adresse, 'adresse', 255);
        }
        
        return !$this->hasErrors();
    }
    
    public function validateCredential($data) {
        $this->clearErrors();
        
        // Champs requis
        if (!isset($data->nom_site_compte) || !$this->required($data->nom_site_compte, 'nom_site_compte')) {
            return false;
        }
        if (!isset($data->nom_utilisateur_email) || !$this->required($data->nom_utilisateur_email, 'nom_utilisateur_email')) {
            return false;
        }
        
        // Validation du nom du site
        $this->minLength($data->nom_site_compte, 'nom_site_compte', 2);
        $this->maxLength($data->nom_site_compte, 'nom_site_compte', 100);
        
        // Validation du nom d'utilisateur/email
        $this->minLength($data->nom_utilisateur_email, 'nom_utilisateur_email', 2);
        $this->maxLength($data->nom_utilisateur_email, 'nom_utilisateur_email', 255);
        
        // Validation du mot de passe (optionnel mais si fourni, doit être fort)
        if (!empty($data->mot_de_passe_chiffre)) {
            $this->password($data->mot_de_passe_chiffre, 'mot_de_passe_chiffre');
        }
        
        // Validation de la catégorie
        if (!empty($data->categorie)) {
            $allowedCategories = ['Personnel', 'Professionnel', 'Social', 'Financier', 'Autre'];
            $this->inArray($data->categorie, 'categorie', $allowedCategories);
        }
        
        return !$this->hasErrors();
    }
    
    public function validateNote($data) {
        $this->clearErrors();
        
        // Champs requis
        if (!isset($data->titre) || !$this->required($data->titre, 'titre')) {
            return false;
        }
        if (!isset($data->contenu) || !$this->required($data->contenu, 'contenu')) {
            return false;
        }
        
        // Validation du titre
        $this->minLength($data->titre, 'titre', 2);
        $this->maxLength($data->titre, 'titre', 200);
        
        // Validation du sous-titre
        if (!empty($data->sous_titre)) {
            $this->maxLength($data->sous_titre, 'sous_titre', 200);
        }
        
        // Validation du contenu
        $this->minLength($data->contenu, 'contenu', 5);
        
        return !$this->hasErrors();
    }
    
    public function validateTask($data) {
        $this->clearErrors();
        
        // Champs requis
        if (!isset($data->titre_tache) || !$this->required($data->titre_tache, 'titre_tache')) {
            return false;
        }
        if (!isset($data->date_heure_debut) || !$this->required($data->date_heure_debut, 'date_heure_debut')) {
            return false;
        }
        
        // Validation du titre
        $this->minLength($data->titre_tache, 'titre_tache', 2);
        $this->maxLength($data->titre_tache, 'titre_tache', 200);
        
        // Validation des dates
        $this->datetime($data->date_heure_debut, 'date_heure_debut');
        
        if (!empty($data->date_heure_fin)) {
            $this->datetime($data->date_heure_fin, 'date_heure_fin');
            
            // Vérifier que la date de fin est après la date de début
            if (!$this->hasErrors()) {
                $debut = new DateTime($data->date_heure_debut);
                $fin = new DateTime($data->date_heure_fin);
                if ($fin <= $debut) {
                    $this->addError('date_heure_fin', 'La date de fin doit être postérieure à la date de début');
                }
            }
        }
        
        // Validation de la priorité
        if (!empty($data->priorite)) {
            $allowedPriorities = ['Basse', 'Moyenne', 'Haute'];
            $this->inArray($data->priorite, 'priorite', $allowedPriorities);
        }
        
        // Validation du statut
        if (!empty($data->statut)) {
            $allowedStatuses = ['À faire', 'En cours', 'Terminé', 'Annulé'];
            $this->inArray($data->statut, 'statut', $allowedStatuses);
        }
        
        return !$this->hasErrors();
    }
    
    // Méthode pour retourner les erreurs formatées pour JSON
    public function getJsonErrors() {
        return json_encode(['errors' => $this->errors]);
    }
}
?>
