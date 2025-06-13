// ai_one_flutter/lib/viewmodels/contact_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/contact.dart';
import 'package:ai_one_flutter/services/api_service.dart';

class ContactViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Contact> _allContacts = []; // Stocke tous les contacts
  String _searchTerm = ''; // Terme de recherche
  bool _isLoading = false;
  String? _errorMessage;

  // Getter pour les contacts filtrés
  List<Contact> get contacts {
    if (_searchTerm.isEmpty) {
      return _allContacts;
    } else {
      return _allContacts.where((contact) {
        final lowerSearchTerm = _searchTerm.toLowerCase();
        return contact.nomComplet.toLowerCase().contains(lowerSearchTerm) ||
               contact.adresseEmail.toLowerCase().contains(lowerSearchTerm) ||
               (contact.numeroTelephone?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
               (contact.profession?.toLowerCase().contains(lowerSearchTerm) ?? false);
      }).toList();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchTerm => _searchTerm;

  // Nouvelle méthode pour définir le terme de recherche
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners(); // Informe les widgets qu'ils doivent se reconstruire avec le nouveau filtre
  }

  Future<void> fetchContacts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allContacts = await _apiService.getContacts(); // Charge tous les contacts
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des contacts: $e';
      print('Erreur ContactViewModel: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addContact(Map<String, dynamic> contactData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.createContact(contactData);
      await fetchContacts(); // Rafraîchit la liste après ajout
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout du contact: $e';
      print('Erreur ContactViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateContact(int id, Map<String, dynamic> contactData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateContact(id, contactData);
      await fetchContacts(); // Rafraîchit la liste après mise à jour
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du contact: $e';
      print('Erreur ContactViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteContact(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteContact(id);
      await fetchContacts(); // Rafraîchit la liste après suppression
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du contact: $e';
      print('Erreur ContactViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}