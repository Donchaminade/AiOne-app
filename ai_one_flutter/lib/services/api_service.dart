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
  //  static const String _baseUrl = 'http://10.0.2.2/ai-one/api_php/api';
   static const String _baseUrl = 'http://192.168.196.118/ai-one/api_php/api';
   
  // Pour iOS, vous pouvez utiliser 'http://localhost:8000' ou 'http://127.0.0.1:8000'

  //static const String _baseUrl = 'http://127.0.0.1:8000'; // Pour iOS Simulator ou Web

  // Méthode d'aide pour construire les headers (sans authentification)
  Map<String, String> _getHeaders({String contentType = 'application/json'}) {
    return {'Content-Type': contentType};
  }

  // --- Fonctions CRUD des Contacts ---
  Future<List<Contact>> getContacts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/contacts/'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Contact>.from(l.map((model) => Contact.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des contacts: ${response.body}');
    }
  }

  Future<void> createContact(Map<String, dynamic> contactData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/contacts/'),
      headers: _getHeaders(),
      body: json.encode(contactData),
    );

    if (response.statusCode != 201) { // Changed to 201 for creation success
      throw Exception('Échec de la création du contact: ${response.body}');
    }
  }

  Future<void> updateContact(int id, Map<String, dynamic> contactData) async {
    final response = await http.put( // ou patch si votre API utilise PATCH
      Uri.parse('$_baseUrl/contacts/$id'),
      headers: _getHeaders(),
      body: json.encode(contactData),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour du contact: ${response.body}');
    }
  }

  Future<void> deleteContact(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/contacts/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 204) { // Changed to 204 for no content success
      throw Exception('Échec de la suppression du contact: ${response.body}');
    }
  }

  // --- Fonctions CRUD des Notes ---
  Future<List<Note>> getNotes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/notes/'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Note>.from(l.map((model) => Note.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des notes: ${response.body}');
    }
  }

  Future<void> createNote(Map<String, dynamic> noteData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/notes/'),
      headers: _getHeaders(),
      body: json.encode(noteData),
    );

    if (response.statusCode != 201) {
      throw Exception('Échec de la création de la note: ${response.body}');
    }
  }

  Future<void> updateNote(int id, Map<String, dynamic> noteData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/notes/$id'),
      headers: _getHeaders(),
      body: json.encode(noteData),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour de la note: ${response.body}');
    }
  }

  Future<void> deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/notes/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Échec de la suppression de la note: ${response.body}');
    }
  }

  // --- Fonctions CRUD des Credentials ---
  Future<List<Credential>> getCredentials() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/credentials/'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Credential>.from(l.map((model) => Credential.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des identifiants: ${response.body}');
    }
  }

  Future<void> createCredential(Map<String, dynamic> credentialData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/credentials/'),
      headers: _getHeaders(),
      body: json.encode(credentialData),
    );

    if (response.statusCode != 201) {
      throw Exception('Échec de la création de l\'identifiant: ${response.body}');
    }
  }

  Future<void> updateCredential(int id, Map<String, dynamic> credentialData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/credentials/$id'),
      headers: _getHeaders(),
      body: json.encode(credentialData),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour de l\'identifiant: ${response.body}');
    }
  }

  Future<void> deleteCredential(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/credentials/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Échec de la suppression de l\'identifiant: ${response.body}');
    }
  }

  // --- Fonctions CRUD des Tasks ---
  Future<List<Task>> getTasks() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tasks/'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Task>.from(l.map((model) => Task.fromJson(model)));
    } else {
      throw Exception('Échec du chargement des tâches: ${response.body}');
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks/'),
      headers: _getHeaders(),
      body: json.encode(taskData),
    );

    if (response.statusCode != 201) {
      throw Exception('Échec de la création de la tâche: ${response.body}');
    }
  }

  Future<void> updateTask(int id, Map<String, dynamic> taskData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tasks/$id'),
      headers: _getHeaders(),
      body: json.encode(taskData),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour de la tâche: ${response.body}');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tasks/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Échec de la suppression de la tâche: ${response.body}');
    }
  }
}