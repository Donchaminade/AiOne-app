<?php
// api_php/api/contacts.php

// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle OPTIONS method for CORS pre-flight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include required files
require_once __DIR__ . '/../includes/Database.php';
require_once __DIR__ . '/../includes/Contact.php';
require_once __DIR__ . '/../includes/Validator.php';
require_once __DIR__ . '/../includes/Logger.php';
require_once __DIR__ . '/../includes/RateLimiter.php';

// Initialize rate limiter
$rateLimiter = new RateLimiter();
$rateLimiter->checkRateLimit();

// Instantiate database and contact object
$database = Database::getInstance();
$db = $database->getConnection();

$contact = new Contact($db);
$validator = new Validator();

// Get HTTP method
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? $_GET['id'] : null;

// Log the API request
Logger::logRequest($method, '/api/contacts' . ($id ? "/$id" : ''), $_GET);

switch ($method) {
    case 'GET':
        if ($id) {
            // Read single contact
            if (!filter_var($id, FILTER_VALIDATE_INT)) {
                http_response_code(400);
                echo json_encode(["error" => true, "message" => "Invalid contact ID"]);
                break;
            }
            
            $contact->id = $id;
            if ($contact->readOne()) {
                http_response_code(200);
                echo json_encode([
                    "success" => true,
                    "data" => [
                        "id" => $contact->id,
                        "nom_complet" => $contact->nom_complet,
                        "profession" => $contact->profession,
                        "numero_telephone" => $contact->numero_telephone,
                        "adresse_email" => $contact->adresse_email,
                        "adresse" => $contact->adresse,
                        "entreprise_organisation" => $contact->entreprise_organisation,
                        "date_naissance" => $contact->date_naissance,
                        "tags_labels" => $contact->tags_labels,
                        "notes_specifiques" => $contact->notes_specifiques,
                        "created_at" => $contact->created_at,
                        "updated_at" => $contact->updated_at
                    ]
                ]);
                Logger::info('Contact retrieved successfully', ['contact_id' => $id]);
            } else {
                http_response_code(404);
                echo json_encode(["error" => true, "message" => "Contact not found"]);
                Logger::warning('Contact not found', ['contact_id' => $id]);
            }
        } else {
            // Read contacts with pagination and search
            $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
            $limit = isset($_GET['limit']) ? min(100, max(1, (int)$_GET['limit'])) : 10;
            $search = isset($_GET['search']) ? trim($_GET['search']) : '';
            $orderBy = isset($_GET['orderBy']) ? $_GET['orderBy'] : 'created_at';
            $orderDir = isset($_GET['orderDir']) ? strtoupper($_GET['orderDir']) : 'DESC';
            
            try {
                $stmt = $contact->read($page, $limit, $search, $orderBy, $orderDir);
                $totalContacts = $contact->count($search);
                $totalPages = ceil($totalContacts / $limit);
                
                $contacts_arr = [];
                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                    $contacts_arr[] = [
                        "id" => $row['id'],
                        "nom_complet" => $row['nom_complet'],
                        "profession" => $row['profession'],
                        "numero_telephone" => $row['numero_telephone'],
                        "adresse_email" => $row['adresse_email'],
                        "adresse" => $row['adresse'],
                        "entreprise_organisation" => $row['entreprise_organisation'],
                        "date_naissance" => $row['date_naissance'],
                        "tags_labels" => $row['tags_labels'],
                        "notes_specifiques" => $row['notes_specifiques'],
                        "created_at" => $row['created_at'],
                        "updated_at" => $row['updated_at']
                    ];
                }
                
                http_response_code(200);
                echo json_encode([
                    "success" => true,
                    "data" => $contacts_arr,
                    "pagination" => [
                        "page" => $page,
                        "limit" => $limit,
                        "total" => $totalContacts,
                        "totalPages" => $totalPages,
                        "hasNext" => $page < $totalPages,
                        "hasPrev" => $page > 1
                    ],
                    "search" => $search,
                    "orderBy" => $orderBy,
                    "orderDir" => $orderDir
                ]);
                
                Logger::info('Contacts list retrieved', [
                    'page' => $page,
                    'limit' => $limit,
                    'total' => $totalContacts,
                    'search' => $search
                ]);
            } catch (Exception $e) {
                Logger::error('Error retrieving contacts list', ['error' => $e->getMessage()]);
                http_response_code(500);
                echo json_encode(["error" => true, "message" => "Internal server error"]);
            }
        }
        break;

    case 'POST':
        try {
            $data = json_decode(file_get_contents("php://input"));
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                http_response_code(400);
                echo json_encode(["error" => true, "message" => "Invalid JSON data"]);
                break;
            }
            
            // Validate input data
            if (!$validator->validateContact($data)) {
                http_response_code(400);
                echo json_encode([
                    "error" => true,
                    "message" => "Validation failed",
                    "errors" => $validator->getErrors()
                ]);
                Logger::warning('Contact creation failed - validation error', [
                    'errors' => $validator->getErrors()
                ]);
                break;
            }
            
            // Check if email already exists
            $contact->adresse_email = $data->adresse_email;
            if ($contact->emailExists()) {
                http_response_code(409);
                echo json_encode([
                    "error" => true,
                    "message" => "A contact with this email already exists"
                ]);
                Logger::warning('Contact creation failed - email exists', [
                    'email' => $data->adresse_email
                ]);
                break;
            }
            
            // Set contact properties
            $contact->nom_complet = $data->nom_complet;
            $contact->profession = $data->profession ?? '';
            $contact->numero_telephone = $data->numero_telephone ?? '';
            $contact->adresse = $data->adresse ?? '';
            $contact->entreprise_organisation = $data->entreprise_organisation ?? '';
            $contact->date_naissance = $data->date_naissance ?? null;
            $contact->tags_labels = $data->tags_labels ?? '';
            $contact->notes_specifiques = $data->notes_specifiques ?? '';
            
            if ($contact->create()) {
                http_response_code(201);
                echo json_encode([
                    "success" => true,
                    "message" => "Contact created successfully"
                ]);
                Logger::info('Contact created successfully', [
                    'nom_complet' => $data->nom_complet,
                    'adresse_email' => $data->adresse_email
                ]);
            } else {
                http_response_code(500);
                echo json_encode([
                    "error" => true,
                    "message" => "Failed to create contact"
                ]);
                Logger::error('Failed to create contact in database');
            }
            
        } catch (Exception $e) {
            Logger::error('Error in contact creation', ['error' => $e->getMessage()]);
            http_response_code(500);
            echo json_encode(["error" => true, "message" => "Internal server error"]);
        }
        break;

    case 'PUT':
        // Get raw data
        $data = json_decode(file_get_contents("php://input"));

        // Make sure ID and data are not empty
        if (
            !empty($id) &&
            !empty($data->nom_complet) &&
            !empty($data->adresse_email)
        ) {
            // Set ID property of contact to be edited
            $contact->id = $id;

            // Set contact property values
            $contact->nom_complet = $data->nom_complet;
            $contact->profession = isset($data->profession) ? $data->profession : null;
            $contact->numero_telephone = isset($data->numero_telephone) ? $data->numero_telephone : null;
            $contact->adresse_email = $data->adresse_email;
            $contact->adresse = isset($data->adresse) ? $data->adresse : null;
            $contact->entreprise_organisation = isset($data->entreprise_organisation) ? $data->entreprise_organisation : null;
            $contact->date_naissance = isset($data->date_naissance) ? $data->date_naissance : null;
            $contact->tags_labels = isset($data->tags_labels) ? $data->tags_labels : null;
            $contact->notes_specifiques = isset($data->notes_specifiques) ? $data->notes_specifiques : null;

            // Update the contact
            if ($contact->update()) {
                http_response_code(200); // OK
                echo json_encode(array("message" => "Contact was updated."));
            } else {
                http_response_code(503); // Service unavailable
                echo json_encode(array("message" => "Unable to update contact."));
            }
        } else {
            http_response_code(400); // Bad request
            echo json_encode(array("message" => "Unable to update contact. Data or ID is incomplete."));
        }
        break;

    case 'DELETE':
        // Make sure ID is not empty
        if (!empty($id)) {
            // Set contact ID to be deleted
            $contact->id = $id;

            // Delete the contact
            if ($contact->delete()) {
                http_response_code(204); // No Content
                echo json_encode(array("message" => "Contact was deleted."));
            } else {
                http_response_code(503); // Service unavailable
                echo json_encode(array("message" => "Unable to delete contact."));
            }
        } else {
            http_response_code(400); // Bad request
            echo json_encode(array("message" => "Unable to delete contact. ID is missing."));
        }
        break;

    default:
        // Method not allowed
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed."));
        break;
}
?>