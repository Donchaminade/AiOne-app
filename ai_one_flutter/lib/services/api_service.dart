// ai_one_flutter/lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // NOUVEL IMPORT

import 'package:ai_one_flutter/models/contact.dart';
import 'package:ai_one_flutter/models/note.dart';
import 'package:ai_one_flutter/models/credential.dart';
import 'package:ai_one_flutter/models/task.dart';

class ApiService {
  // REMPLACEZ CETTE URL PAR L'ADRESSE IP DE VOTRE MACHINE SI VOUS UTILISEZ UN ÉMULATEUR/TÉLÉPHONE RÉEL
  // Pour un émulateur Android, '10.0.2.2' pointe vers votre machine hôte.
  // Pour un émulateur iOS, 'localhost' ou '127.0.0.1' fonctionne.
  // Pour un appareil physique, vous devrez utiliser l'adresse IP de votre machine sur le réseau local.
  static const String _baseUrl = 'http://10.0.2.2:8000';
  // static const String _baseUrl = 'http://127.0.0.1:8000'; // Pour iOS Simulator ou Web

  String? _authToken; // Pour stocker le token JWT

  // Méthode pour obtenir le token stocké (utilisée au démarrage de l'app)
  Future<String?> getAuthToken() async {
    if (_authToken != null) {
      return _authToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // Méthode pour sauvegarder le token
  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _authToken = token;
  }

  // Méthode pour supprimer le token
  Future<void> _deleteAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = null;
  }

  // Méthode pour l'enregistrement
  Future<void> register({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Échec de l\'enregistrement');
    }
  }

  // Méthode pour la connexion
  Future<String> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email, // FastAPI s'attend à 'username' pour le champ email
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      await _saveAuthToken(token); // Sauvegarde le token
      return token;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Échec de la connexion');
    }
  }

  // Méthode pour la déconnexion
  Future<void> logout() async {
    await _deleteAuthToken();
  }

  // Méthode générique pour faire des requêtes API avec authentification
  Future<http.Response> _authenticatedRequest(
      Future<http.Response> Function() requestFunction) async {
    // Tente de récupérer le token si non déjà chargé
    if (_authToken == null) {
      await getAuthToken();
    }

    if (_authToken == null) {
      throw Exception('Aucun jeton d\'authentification disponible. Veuillez vous connecter.');
    }

    try {
      final response = await requestFunction();
      if (response.statusCode == 401) {
        // Token expiré ou invalide, déconnexion forcée
        await logout();
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Méthode d'aide pour construire les headers avec le token
  Map<String, String> _getAuthHeaders({String contentType = 'application/json'}) {
    return {
      'Content-Type': contentType,
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // --- Fonctions CRUD des Contacts ---
  Future<List<Contact>> getContacts() async {
    final response = await _authenticatedRequest(() => http.get(
          Uri.parse('$_baseUrl/contacts/'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Contact>.from(l.map((model) => Contact.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des contacts: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> createContact(Map<String, dynamic> contactData) async {
    final response = await _authenticatedRequest(() => http.post(
          Uri.parse('$_baseUrl/contacts/'),
          headers: _getAuthHeaders(),
          body: json.encode(contactData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la création du contact: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> updateContact(int id, Map<String, dynamic> contactData) async {
    final response = await _authenticatedRequest(() => http.put( // ou patch si votre API utilise PATCH
          Uri.parse('$_baseUrl/contacts/$id'),
          headers: _getAuthHeaders(),
          body: json.encode(contactData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour du contact: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteContact(int id) async {
    final response = await _authenticatedRequest(() => http.delete(
          Uri.parse('$_baseUrl/contacts/$id'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression du contact: ${response.statusCode} ${response.body}');
    }
  }

  // --- Fonctions CRUD des Notes ---
  Future<List<Note>> getNotes() async {
    final response = await _authenticatedRequest(() => http.get(
          Uri.parse('$_baseUrl/notes/'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Note>.from(l.map((model) => Note.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des notes: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> createNote(Map<String, dynamic> noteData) async {
    final response = await _authenticatedRequest(() => http.post(
          Uri.parse('$_baseUrl/notes/'),
          headers: _getAuthHeaders(),
          body: json.encode(noteData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la création de la note: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> updateNote(int id, Map<String, dynamic> noteData) async {
    final response = await _authenticatedRequest(() => http.put(
          Uri.parse('$_baseUrl/notes/$id'),
          headers: _getAuthHeaders(),
          body: json.encode(noteData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour de la note: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteNote(int id) async {
    final response = await _authenticatedRequest(() => http.delete(
          Uri.parse('$_baseUrl/notes/$id'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression de la note: ${response.statusCode} ${response.body}');
    }
  }

  // --- Fonctions CRUD des Credentials ---
  Future<List<Credential>> getCredentials() async {
    final response = await _authenticatedRequest(() => http.get(
          Uri.parse('$_baseUrl/credentials/'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Credential>.from(l.map((model) => Credential.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des identifiants: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> createCredential(Map<String, dynamic> credentialData) async {
    final response = await _authenticatedRequest(() => http.post(
          Uri.parse('$_baseUrl/credentials/'),
          headers: _getAuthHeaders(),
          body: json.encode(credentialData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la création de l\'identifiant: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> updateCredential(int id, Map<String, dynamic> credentialData) async {
    final response = await _authenticatedRequest(() => http.put(
          Uri.parse('$_baseUrl/credentials/$id'),
          headers: _getAuthHeaders(),
          body: json.encode(credentialData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour de l\'identifiant: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteCredential(int id) async {
    final response = await _authenticatedRequest(() => http.delete(
          Uri.parse('$_baseUrl/credentials/$id'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression de l\'identifiant: ${response.statusCode} ${response.body}');
    }
  }

  // --- Fonctions CRUD des Tasks ---
  Future<List<Task>> getTasks() async {
    final response = await _authenticatedRequest(() => http.get(
          Uri.parse('$_baseUrl/tasks/'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Task>.from(l.map((model) => Task.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des tâches: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final response = await _authenticatedRequest(() => http.post(
          Uri.parse('$_baseUrl/tasks/'),
          headers: _getAuthHeaders(),
          body: json.encode(taskData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la création de la tâche: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> updateTask(int id, Map<String, dynamic> taskData) async {
    final response = await _authenticatedRequest(() => http.put(
          Uri.parse('$_baseUrl/tasks/$id'),
          headers: _getAuthHeaders(),
          body: json.encode(taskData),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour de la tâche: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await _authenticatedRequest(() => http.delete(
          Uri.parse('$_baseUrl/tasks/$id'),
          headers: _getAuthHeaders(),
        ));

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression de la tâche: ${response.statusCode} ${response.body}');
    }
  }
}