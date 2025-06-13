// ai_one_flutter/lib/viewmodels/credential_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/credential.dart';
import 'package:ai_one_flutter/services/api_service.dart';

class CredentialViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Credential> _allCredentials = [];
  String _searchTerm = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Credential> get credentials {
    if (_searchTerm.isEmpty) {
      return _allCredentials;
    } else {
      return _allCredentials.where((credential) {
        final lowerSearchTerm = _searchTerm.toLowerCase();
        return credential.nomSiteCompte.toLowerCase().contains(lowerSearchTerm) ||
               credential.nomUtilisateurEmail.toLowerCase().contains(lowerSearchTerm) ||
               (credential.categorie?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
               (credential.autresInfosChiffre?.toLowerCase().contains(lowerSearchTerm) ?? false);
      }).toList();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchTerm => _searchTerm;

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  Future<void> fetchCredentials() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allCredentials = await _apiService.getCredentials();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des identifiants: $e';
      print('Erreur CredentialViewModel: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCredential(Map<String, dynamic> credentialData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.createCredential(credentialData);
      await fetchCredentials();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de l\'identifiant: $e';
      print('Erreur CredentialViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCredential(int id, Map<String, dynamic> credentialData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateCredential(id, credentialData);
      await fetchCredentials();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de l\'identifiant: $e';
      print('Erreur CredentialViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCredential(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteCredential(id);
      await fetchCredentials();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de l\'identifiant: $e';
      print('Erreur CredentialViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}