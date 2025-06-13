// ai_one_flutter/lib/viewmodels/task_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/task.dart';
import 'package:ai_one_flutter/services/api_service.dart';

class TaskViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Task> _allTasks = [];
  String _searchTerm = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks {
    if (_searchTerm.isEmpty) {
      return _allTasks;
    } else {
      return _allTasks.where((task) {
        final lowerSearchTerm = _searchTerm.toLowerCase();
        return task.titreTache.toLowerCase().contains(lowerSearchTerm) ||
               (task.detailsDescription?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
               (task.priorite?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
               (task.statut?.toLowerCase().contains(lowerSearchTerm) ?? false);
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

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allTasks = await _apiService.getTasks();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des tâches: $e';
      print('Erreur TaskViewModel: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(Map<String, dynamic> taskData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.createTask(taskData);
      await fetchTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de la tâche: $e';
      print('Erreur TaskViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(int id, Map<String, dynamic> taskData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.updateTask(id, taskData);
      await fetchTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la tâche: $e';
      print('Erreur TaskViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteTask(id);
      await fetchTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de la tâche: $e';
      print('Erreur TaskViewModel: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}