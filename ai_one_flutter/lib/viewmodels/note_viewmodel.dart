// ai_one_flutter/lib/viewmodels/note_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/note.dart';
import 'package:ai_one_flutter/services/api_service.dart';

class NoteViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Note> _allNotes = [];
  String _searchTerm = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Note> get notes {
    if (_searchTerm.isEmpty) {
      return _allNotes;
    } else {
      return _allNotes.where((note) {
        final lowerSearchTerm = _searchTerm.toLowerCase();
        return note.titre.toLowerCase().contains(lowerSearchTerm) ||
               (note.sousTitre?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
               (note.contenu?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
               (note.dossiers?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
               (note.tagsLabels?.toLowerCase().contains(lowerSearchTerm) ?? false);
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

  Future<void> fetchNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allNotes = await _apiService.getNotes();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des notes: $e';
      print('Erreur NoteViewModel: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addNote(Map<String, dynamic> noteData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.createNote(noteData);
      await fetchNotes();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de la note: $e';
      print('Erreur NoteViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote(int id, Map<String, dynamic> noteData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateNote(id, noteData);
      await fetchNotes();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la note: $e';
      print('Erreur NoteViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteNote(id);
      await fetchNotes();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de la note: $e';
      print('Erreur NoteViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}