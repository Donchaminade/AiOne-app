// ai_one_flutter/lib/screens/tasks/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/task.dart';
import 'package:ai_one_flutter/screens/tasks/task_form_screen.dart';
import 'package:ai_one_flutter/screens/tasks/task_detail_screen.dart';
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks();
    });
    _searchController.addListener(() {
      Provider.of<TaskViewModel>(context, listen: false).setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddEditTask({Task? task}) async {
    final bool? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opération terminée avec succès.')),
      );
    }
  }

  Future<void> _confirmAndDeleteTask(int id, String titreTache) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la tâche "$titreTache" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await Provider.of<TaskViewModel>(context, listen: false).deleteTask(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tâche "$titreTache" supprimée avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de la tâche "$titreTache".')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher une tâche',
                  hintText: 'Entrez un titre, statut, etc.',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            taskViewModel.setSearchTerm('');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: taskViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskViewModel.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              taskViewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : taskViewModel.tasks.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? 'Aucune tâche trouvée pour "${_searchController.text}".'
                                    : 'Aucune tâche trouvée. Appuyez sur "+" pour en ajouter une.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: taskViewModel.tasks.length,
                              itemBuilder: (context, index) {
                                final task = taskViewModel.tasks[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: ListTile(
                                    leading: Icon(
                                      task.statut == 'Terminé' ? Icons.check_circle_outline : Icons.pending_actions,
                                      color: task.statut == 'Terminé' ? Colors.green : Colors.orange,
                                    ),
                                    title: Text(
                                      task.titreTache,
                                      style: TextStyle(
                                        decoration: task.statut == 'Terminé' ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Début: ${task.formattedDateHeureDebut}' +
                                          (task.priorite != null && task.priorite!.isNotEmpty ? ' | Priorité: ${task.priorite!}' : ''),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _navigateToAddEditTask(task: task),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _confirmAndDeleteTask(task.id, task.titreTache),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TaskDetailScreen(task: task),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }
}