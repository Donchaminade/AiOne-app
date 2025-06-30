// ai_one_flutter/lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:ai_one_flutter/models/contact.dart';
import 'package:ai_one_flutter/models/note.dart';
import 'package:ai_one_flutter/models/credential.dart';
import 'package:ai_one_flutter/models/task.dart';

class ApiService {
  // REMPLACEZ CETTE URL PAR L'ADRESSE IP DE VOTRE MACHINE SI VOUS UTILISEZ UN ÉMULATEUR/TÉLÉPHONE RÉEL
  // Pour un émulateur Android, '10.0.2.2' pointe vers votre machine hôte.
  // Pour un émulateur iOS, 'localhost' ou '127.0.0.1' fonctionne.
  // Pour un appareil physique, vous devrez utiliser l'adresse IP de votre machine sur le réseau local.
  static const String _baseUrl = 'http://10.0.2.2/ai-one/api_php/api';
  //static const String _baseUrl = 'http://192.168.196.118/ai-one/api_php/api';

  // Pour iOS, vous pouvez utiliser 'http://localhost:8000' ou 'http://127.0.0.1:8000'
  // static const String _baseUrl = 'http://127.0.0.1:8000'; // Pour iOS Simulator ou Web

  // Headers communs pour les requêtes JSON
  Map<String, String> _getHeaders({String contentType = 'application/json'}) {
    return {'Content-Type': contentType};
  }

  /// Méthode d'aide pour gérer les réponses HTTP de manière centralisée.
  /// Vérifie le statut et décode le corps JSON. Lance une exception en cas d'erreur.
  dynamic _handleResponse(http.Response response) {
    // Utile pour le débogage : loggez le statut et le corps de la réponse
    print('API Response - URL: ${response.request?.url}, Status: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204) {
        return null; // 204 No Content n'a pas de corps à décoder
      }
      if (response.body.isEmpty) {
        return null; // Réponse vide mais statut 2xx
      }
      try {
        final decodedBody = json.decode(response.body);
        // Si la réponse est un objet avec une clé 'records', retournez le contenu de 'records'
        if (decodedBody is Map && decodedBody.containsKey('records')) {
            return decodedBody['records'];
        }
        return decodedBody; // Sinon, retournez le corps décodé tel quel
      } on FormatException catch (e) {
        throw FormatException(
          'Erreur de format JSON: La réponse du serveur n\'est pas un JSON valide. '
          'Détails: ${e.message}. Corps: "${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}"',
        );
      }
    } else {
      String errorMessage = 'Erreur inconnue du serveur (Code ${response.statusCode}).';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && (errorData.containsKey('message') || errorData.containsKey('error'))) {
          errorMessage = errorData['message'] ?? errorData['error'];
        } else if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      } on FormatException {
        errorMessage = response.body.isNotEmpty ? response.body : 'Aucun détail d\'erreur du serveur.';
      }
      throw Exception('Échec de la requête: Statut ${response.statusCode}. Message: $errorMessage');
    }
  }

  // --- Fonctions CRUD des Contacts ---
  Future<List<Contact>> getContacts() async {
    // Assurez-vous que l'API pour les contacts suit la même convention si ce n'est pas déjà le cas
    final response = await http.get(Uri.parse('$_baseUrl/contacts.php'), headers: _getHeaders());
    final List<dynamic>? data = _handleResponse(response);
    if (data == null) return [];
    return List<Contact>.from(data.map((model) => Contact.fromJson(model as Map<String, dynamic>)));
  }

  Future<void> createContact(Map<String, dynamic> contactData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/contacts.php'),
      headers: _getHeaders(),
      body: json.encode(contactData),
    );
    _handleResponse(response);
  }

  Future<void> updateContact(int id, Map<String, dynamic> contactData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/contacts.php?id=$id'), // Utilisation de query parameter pour l'ID
      headers: _getHeaders(),
      body: json.encode(contactData),
    );
    _handleResponse(response);
  }

  Future<void> deleteContact(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/contacts.php?id=$id'), // Utilisation de query parameter pour l'ID
      headers: _getHeaders(),
    );
    _handleResponse(response);
  }

  // --- Fonctions CRUD des Notes ---
  Future<List<Note>> getNotes() async {
    // Assurez-vous que l'API pour les notes suit la même convention si ce n'est pas déjà le cas
    final response = await http.get(Uri.parse('$_baseUrl/notes.php'), headers: _getHeaders());
    final List<dynamic>? data = _handleResponse(response);
    if (data == null) return [];
    return List<Note>.from(data.map((model) => Note.fromJson(model as Map<String, dynamic>)));
  }

  Future<void> createNote(Map<String, dynamic> noteData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/notes.php'),
      headers: _getHeaders(),
      body: json.encode(noteData),
    );
    _handleResponse(response);
  }

  Future<void> updateNote(int id, Map<String, dynamic> noteData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/notes.php?id=$id'),
      headers: _getHeaders(),
      body: json.encode(noteData),
    );
    _handleResponse(response);
  }

  Future<void> deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/notes.php?id=$id'),
      headers: _getHeaders(),
    );
    _handleResponse(response);
  }

  // --- Fonctions CRUD des Credentials ---
  Future<List<Credential>> getCredentials() async {
    final response = await http.get(Uri.parse('$_baseUrl/credentials.php'), headers: _getHeaders());
    final dynamic data = _handleResponse(response); // Ne pas spécifier List<dynamic> ici car peut être un Map avec 'records'
    if (data == null) return [];
    // Si la réponse est un Map avec 'records' (cas de la liste vide avec message) ou un tableau directement
    if (data is List) {
        return List<Credential>.from(data.map((model) => Credential.fromJson(model as Map<String, dynamic>)));
    } else if (data is Map && data.containsKey('records')) {
        // Cela devrait être géré par _handleResponse, mais une double vérification ne fait pas de mal
        return List<Credential>.from(data['records'].map((model) => Credential.fromJson(model as Map<String, dynamic>)));
    } else {
        // Gérer le cas où la réponse est un objet unique (lecture d'un seul) mais qu'on attend une liste
        // Cela ne devrait pas arriver pour getCredentials(), mais par précaution.
        return [];
    }
  }

  // Récupérer un seul Credential par ID (nouveau, pour l'écran de détail)
  Future<Credential?> getCredentialById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/credentials.php?id=$id'), headers: _getHeaders());
    final dynamic data = _handleResponse(response);
    if (data == null) return null;
    return Credential.fromJson(data as Map<String, dynamic>);
  }

  Future<void> createCredential(Map<String, dynamic> credentialData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/credentials.php'),
      headers: _getHeaders(),
      body: json.encode(credentialData),
    );
    _handleResponse(response);
  }

  Future<void> updateCredential(int id, Map<String, dynamic> credentialData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/credentials.php?id=$id'), // Utilisation de query parameter pour l'ID
      headers: _getHeaders(),
      body: json.encode(credentialData),
    );
    _handleResponse(response);
  }

  Future<void> deleteCredential(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/credentials.php?id=$id'), // Utilisation de query parameter pour l'ID
      headers: _getHeaders(),
    );
    _handleResponse(response);
  }

  // --- Fonctions CRUD des Tasks ---
  Future<List<Task>> getTasks() async {
    // Assurez-vous que l'API pour les tasks suit la même convention si ce n'est pas déjà le cas
    final response = await http.get(Uri.parse('$_baseUrl/tasks.php'), headers: _getHeaders());
    final List<dynamic>? data = _handleResponse(response);
    if (data == null) return [];
    return List<Task>.from(data.map((model) => Task.fromJson(model as Map<String, dynamic>)));
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks.php'),
      headers: _getHeaders(),
      body: json.encode(taskData),
    );
    _handleResponse(response);
  }

  Future<void> updateTask(int id, Map<String, dynamic> taskData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tasks.php?id=$id'),
      headers: _getHeaders(),
      body: json.encode(taskData),
    );
    _handleResponse(response);
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tasks.php?id=$id'),
      headers: _getHeaders(),
    );
    _handleResponse(response);
  }
}