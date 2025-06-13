// ai_one_flutter/lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken; // Le token authentifié
  bool _isAuthenticated = false; // L'état d'authentification

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get authToken => _authToken;
  bool get isAuthenticated => _isAuthenticated;

  // Initialisation : Vérifie si un token existe au démarrage de l'app
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _authToken = await _apiService.getAuthToken();
      _isAuthenticated = _authToken != null;
    } catch (e) {
      print('Erreur lors de la vérification du statut d\'authentification: $e');
      _isAuthenticated = false;
      _errorMessage = 'Erreur de récupération de la session.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _authToken = await _apiService.login(email: email, password: password);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAuthenticated = false;
      _authToken = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.register(email: email, password: password);
      // Après l'enregistrement, on peut choisir de se connecter directement
      // ou de laisser l'utilisateur se connecter manuellement
      // Pour cet exemple, on redirigera vers l'écran de connexion
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.logout();
      _isAuthenticated = false;
      _authToken = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}