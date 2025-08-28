// lib/providers/contacts_provider_improved.dart

import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../models/api_response.dart';
import '../services/improved_api_service.dart';
import '../services/error_handler.dart';

/// Provider amélioré pour les contacts avec pagination et recherche
class ContactsProviderImproved extends ChangeNotifier {
  final ImprovedApiService _apiService = ImprovedApiService.instance;
  
  // État de la liste des contacts
  ContactsListState _contactsState = ContactsListState.initial();
  ContactsListState get contactsState => _contactsState;
  
  // Paramètres de recherche et tri
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  String _orderBy = 'nom_complet';
  String get orderBy => _orderBy;
  
  String _orderDir = 'ASC';
  String get orderDir => _orderDir;
  
  // Contact sélectionné pour les détails
  Contact? _selectedContact;
  Contact? get selectedContact => _selectedContact;
  
  bool _isLoadingContact = false;
  bool get isLoadingContact => _isLoadingContact;
  
  /// Charge la première page des contacts
  Future<void> loadContacts({
    bool refresh = false,
    String? search,
    String? orderBy,
    String? orderDir,
  }) async {
    try {
      // Mettre à jour les paramètres si fournis
      if (search != null) _searchQuery = search;
      if (orderBy != null) _orderBy = orderBy;
      if (orderDir != null) _orderDir = orderDir;
      
      // Définir l'état de chargement approprié
      if (refresh) {
        _contactsState = _contactsState.toRefreshing();
      } else if (_contactsState.isInitial) {
        _contactsState = _contactsState.toLoading();
      }
      notifyListeners();
      
      final response = await _apiService.getContacts(
        page: 1,
        limit: 20,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        orderBy: _orderBy,
        orderDir: _orderDir,
      );
      
      if (response.isSuccess) {
        final paginatedList = PaginatedList.fromApiResponse(response);
        _contactsState = _contactsState.toLoaded(paginatedList);
      } else {
        _contactsState = _contactsState.toError(
          response.message ?? 'Erreur lors du chargement des contacts'
        );
      }
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      _contactsState = _contactsState.toError(apiError.friendlyMessage);
    }
    
    notifyListeners();
  }
  
  /// Charge la page suivante (scroll infini)
  Future<void> loadNextPage() async {
    if (!_contactsState.canLoadMore) return;
    
    try {
      _contactsState = _contactsState.toLoadingMore();
      notifyListeners();
      
      final nextPage = _contactsState.list.pagination.page + 1;
      
      final response = await _apiService.getContacts(
        page: nextPage,
        limit: 20,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        orderBy: _orderBy,
        orderDir: _orderDir,
      );
      
      if (response.isSuccess) {
        final newPage = PaginatedList.fromApiResponse(response);
        _contactsState = _contactsState.appendPage(newPage);
      } else {
        _contactsState = _contactsState.toError(
          response.message ?? 'Erreur lors du chargement'
        );
      }
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      _contactsState = _contactsState.toError(apiError.friendlyMessage);
    }
    
    notifyListeners();
  }
  
  /// Recherche les contacts
  Future<void> searchContacts(String query) async {
    if (query == _searchQuery) return;
    
    _searchQuery = query;
    await loadContacts(refresh: true);
  }
  
  /// Change l'ordre de tri
  Future<void> changeSorting(String orderBy, String orderDir) async {
    if (orderBy == _orderBy && orderDir == _orderDir) return;
    
    _orderBy = orderBy;
    _orderDir = orderDir;
    await loadContacts(refresh: true);
  }
  
  /// Charge un contact spécifique
  Future<void> loadContact(int contactId) async {
    if (_selectedContact?.id == contactId) return;
    
    _isLoadingContact = true;
    _selectedContact = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getContact(contactId);
      
      if (response.isSuccess) {
        _selectedContact = response.data;
      } else {
        // Gérer l'erreur de chargement du contact
        debugPrint('Erreur chargement contact: ${response.message}');
      }
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      debugPrint('Erreur chargement contact: ${apiError.friendlyMessage}');
    }
    
    _isLoadingContact = false;
    notifyListeners();
  }
  
  /// Crée un nouveau contact
  Future<bool> createContact(Map<String, dynamic> contactData) async {
    try {
      final response = await _apiService.createContact(contactData);
      
      if (response.isSuccess) {
        // Recharger la liste pour inclure le nouveau contact
        await loadContacts(refresh: true);
        return true;
      } else {
        // L'erreur sera gérée par l'UI via response.message ou response.errors
        return false;
      }
    } catch (e) {
      // L'erreur sera gérée par l'UI
      return false;
    }
  }
  
  /// Met à jour un contact existant
  Future<bool> updateContact(int contactId, Map<String, dynamic> contactData) async {
    try {
      final response = await _apiService.updateContact(contactId, contactData);
      
      if (response.isSuccess) {
        // Mettre à jour le contact dans la liste si présent
        final currentList = _contactsState.list;
        final contactIndex = currentList.items.indexWhere((c) => c.id == contactId);
        
        if (contactIndex != -1) {
          // Recharger la liste pour avoir les données à jour
          await loadContacts(refresh: true);
        }
        
        // Mettre à jour le contact sélectionné si c'est le même
        if (_selectedContact?.id == contactId) {
          await loadContact(contactId);
        }
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Supprime un contact
  Future<bool> deleteContact(int contactId) async {
    try {
      final response = await _apiService.deleteContact(contactId);
      
      if (response.isSuccess) {
        // Supprimer le contact de la liste locale
        final currentList = _contactsState.list;
        final updatedContacts = currentList.items.where((c) => c.id != contactId).toList();
        
        final updatedList = currentList.copyWith(items: updatedContacts);
        _contactsState = _contactsState.toLoaded(updatedList);
        
        // Effacer le contact sélectionné s'il s'agit du contact supprimé
        if (_selectedContact?.id == contactId) {
          _selectedContact = null;
        }
        
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Efface le contact sélectionné
  void clearSelectedContact() {
    _selectedContact = null;
    notifyListeners();
  }
  
  /// Efface les filtres de recherche
  void clearFilters() {
    _searchQuery = '';
    _orderBy = 'nom_complet';
    _orderDir = 'ASC';
    loadContacts(refresh: true);
  }
  
  /// Getters utilitaires pour l'UI
  bool get hasContacts => _contactsState.list.isNotEmpty;
  bool get isLoading => _contactsState.isLoading;
  bool get isLoadingMore => _contactsState.isLoadingMore;
  bool get isError => _contactsState.isError;
  bool get canLoadMore => _contactsState.canLoadMore;
  bool get isEmpty => _contactsState.isEmpty;
  String? get errorMessage => _contactsState.error;
  List<Contact> get contacts => _contactsState.list.items;
  int get totalContacts => _contactsState.list.pagination.total;
  bool get hasSearch => _searchQuery.isNotEmpty;
  
  /// Informations de pagination pour l'UI
  String get paginationInfo {
    final pagination = _contactsState.list.pagination;
    return '${contacts.length} sur ${pagination.total} contacts';
  }
}

/// Extension pour des méthodes utilitaires
extension ContactsProviderUtils on ContactsProviderImproved {
  /// Trouve un contact par ID dans la liste actuelle
  Contact? findContactById(int contactId) {
    try {
      return contacts.firstWhere((contact) => contact.id == contactId);
    } catch (e) {
      return null;
    }
  }
  
  /// Vérifie si un contact est déjà dans la liste
  bool containsContact(int contactId) {
    return findContactById(contactId) != null;
  }
  
  /// Retourne les options de tri disponibles
  static List<Map<String, String>> get sortOptions => [
    {'label': 'Nom (A-Z)', 'orderBy': 'nom_complet', 'orderDir': 'ASC'},
    {'label': 'Nom (Z-A)', 'orderBy': 'nom_complet', 'orderDir': 'DESC'},
    {'label': 'Email (A-Z)', 'orderBy': 'adresse_email', 'orderDir': 'ASC'},
    {'label': 'Email (Z-A)', 'orderBy': 'adresse_email', 'orderDir': 'DESC'},
    {'label': 'Plus récent', 'orderBy': 'created_at', 'orderDir': 'DESC'},
    {'label': 'Plus ancien', 'orderBy': 'created_at', 'orderDir': 'ASC'},
  ];
}
