<?php
// api_php/api/credentials.php

// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle OPTIONS method for CORS pre-flight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(); // Exit immediately for OPTIONS requests
}

// Include database and object files
// Les chemins sont corrects pour la structure que vous avez montrée (api/credentials.php)
require_once __DIR__ . '/../config/Database.php';   // Contains DatabaseConfig class
require_once __DIR__ . '/../includes/Database.php';   // Contains Database class
require_once __DIR__ . '/../includes/Credential.php'; // Contains Credential class

// Instantiate database and credential object
$database = new Database();
$db = $database->getConnection();

// If DB connection failed and already sent error message, exit.
// This check is good to ensure the script stops if connection fails
if ($db === null) {
    exit();
}

$credential = new Credential($db);

// Get HTTP method
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? $_GET['id'] : null;

switch ($method) {
    case 'GET':
        if ($id) {
            // Read single credential
            $credential->id = $id;
            if ($credential->readOne()) {
                http_response_code(200);
                // ATTENTION: Nous ne retournons PLUS mot_de_passe_chiffre (le hash) au client.
                // autres_infos_chiffre est maintenant en clair et n'a pas besoin d'être déchiffré ici.
                echo json_encode(array(
                    "id" => $credential->id,
                    "nom_site_compte" => $credential->nom_site_compte,
                    "nom_utilisateur_email" => $credential->nom_utilisateur_email,
                    "autres_infos_chiffre" => $credential->autres_infos_chiffre, // Ceci est la donnée en clair (plus de decrypt())
                    "categorie" => $credential->categorie,
                    "created_at" => $credential->created_at,
                    "updated_at" => $credential->updated_at
                ));
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "Identifiant non trouvé."));
            }
        } else {
            // Read all credentials (list view)
            $stmt = $credential->read();
            $num = $stmt->rowCount();

            if ($num > 0) {
                $credentials_arr = array();
                $credentials_arr["records"] = array(); // Pour une structure JSON cohérente (optionnel mais bonne pratique)

                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                    // La méthode read() dans Credential.php ne sélectionne PAS 'mot_de_passe_chiffre' ni 'autres_infos_chiffre' pour la liste.
                    // Donc, aucune modification nécessaire ici pour ces champs.
                    $credential_item = array(
                        "id" => $row['id'],
                        "nom_site_compte" => $row['nom_site_compte'],
                        "nom_utilisateur_email" => $row['nom_utilisateur_email'],
                        "categorie" => $row['categorie'],
                        "created_at" => $row['created_at'],
                        "updated_at" => $row['updated_at']
                    );
                    array_push($credentials_arr["records"], $credential_item);
                }
                http_response_code(200);
                echo json_encode($credentials_arr);
            } else {
                // Return 200 OK with an empty array if no credentials are found
                http_response_code(200);
                echo json_encode(array("message" => "Aucun identifiant trouvé.", "records" => []));
            }
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"));

        // Validate required fields
        if (
            !empty($data->nom_site_compte) &&
            !empty($data->nom_utilisateur_email)
            // mot_de_passe_chiffre et autres_infos_chiffre peuvent être vides, donc pas de !empty() strict
        ) {
            $credential->nom_site_compte = $data->nom_site_compte;
            $credential->nom_utilisateur_email = $data->nom_utilisateur_email;
            // Assurez-vous d'assigner une valeur même si le client n'envoie pas ces champs (pour éviter des notices PHP)
            $credential->mot_de_passe_chiffre = isset($data->mot_de_passe_chiffre) ? $data->mot_de_passe_chiffre : '';
            $credential->autres_infos_chiffre = isset($data->autres_infos_chiffre) ? $data->autres_infos_chiffre : '';
            $credential->categorie = isset($data->categorie) ? $data->categorie : '';

            if ($credential->create()) {
                http_response_code(201); // Created
                echo json_encode(array("message" => "Identifiant créé avec succès."));
            } else {
                http_response_code(503); // Service Unavailable
                echo json_encode(array("message" => "Impossible de créer l'identifiant."));
            }
        } else {
            http_response_code(400); // Bad Request
            echo json_encode(array("message" => "Impossible de créer l'identifiant. Données incomplètes (nom du site et/ou email manquants)."));
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"));

        // Validate required fields
        if (
            !empty($id) && // ID from URL
            !empty($data->nom_site_compte) &&
            !empty($data->nom_utilisateur_email)
        ) {
            $credential->id = $id; // ID from URL
            $credential->nom_site_compte = $data->nom_site_compte;
            $credential->nom_utilisateur_email = $data->nom_utilisateur_email;
            // Mot de passe et autres infos peuvent être optionnels ou vides
            $credential->mot_de_passe_chiffre = isset($data->mot_de_passe_chiffre) ? $data->mot_de_passe_chiffre : '';
            $credential->autres_infos_chiffre = isset($data->autres_infos_chiffre) ? $data->autres_infos_chiffre : '';
            $credential->categorie = isset($data->categorie) ? $data->categorie : '';

            if ($credential->update()) {
                http_response_code(200);
                echo json_encode(array("message" => "Identifiant mis à jour avec succès."));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Impossible de mettre à jour l'identifiant."));
            }
        } else {
            http_response_code(400);
            echo json_encode(array("message" => "Impossible de mettre à jour l'identifiant. Données ou ID manquants."));
        }
        break;

    case 'DELETE':
        if (!empty($id)) {
            $credential->id = $id;
            if ($credential->delete()) {
                http_response_code(204); // No Content - Success with no response body
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Impossible de supprimer l'identifiant."));
            }
        } else {
            http_response_code(400);
            echo json_encode(array("message" => "Impossible de supprimer l'identifiant. ID manquant."));
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(array("message" => "Méthode non autorisée."));
        break;
}
?>