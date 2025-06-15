// ai_one_flutter/lib/screens/tasks/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/task.dart'; // Assurez-vous que ce fichier est correct
import 'package:ai_one_flutter/screens/tasks/task_form_screen.dart'; // Assurez-vous que ce fichier existe
import 'package:ai_one_flutter/screens/tasks/task_detail_screen.dart'; // Assurez-vous que ce fichier existe
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart'; // Assurez-vous que ce fichier est correct

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
    // Nous déclenchons la récupération initiale des tâches une fois que le widget est complètement construit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks();
    });
    // Écoute les changements dans le champ de recherche pour filtrer les tâches en temps réel.
    _searchController.addListener(() {
      Provider.of<TaskViewModel>(context, listen: false).setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    // Il est crucial de retirer le listener et de disposer du contrôleur pour éviter les fuites de mémoire.
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  /// Navigue vers l'écran d'ajout ou de modification d'une tâche.
  /// Si un objet `task` est fourni, l'écran sera en mode modification; sinon, en mode ajout.
  void _navigateToAddEditTask({Task? task}) async {
    final bool? result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TaskFormScreen(task: task),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Ajoute une transition de fondu pour une meilleure expérience utilisateur.
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400), // Durée de la transition.
      ),
    );
    // Si l'opération d'ajout/édition a réussi (result est true) et le widget est toujours monté,
    // rafraîchit la liste des tâches et affiche un message de succès.
    if (result == true && mounted) {
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks(); // Recharge les données.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(task == null ? 'Tâche ajoutée avec succès !' : 'Tâche mise à jour avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Affiche une boîte de dialogue de confirmation avant de supprimer une tâche.
  Future<void> _confirmAndDeleteTask(int id, String titreTache) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Êtes-vous sûr de vouloir supprimer la tâche "$titreTache" ? Cette action est irréversible.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Bords arrondis pour le dialogue.
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Annule la suppression.
            child: Text('Annuler', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirme la suppression.
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Bouton de suppression rouge.
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    // Si la suppression est confirmée, procède à l'action.
    if (confirm == true) {
      final taskViewModel = Provider.of<TaskViewModel>(context, listen: false);
      final success = await taskViewModel.deleteTask(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tâche "$titreTache" supprimée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(taskViewModel.errorMessage ?? 'Erreur lors de la suppression de la tâche "$titreTache".'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Aide à obtenir une couleur de badge en fonction du statut de la tâche.
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'terminée':
        return Colors.green[600]!;
      case 'en cours':
        return Colors.orange[600]!;
      case 'à faire':
        return Colors.blue[600]!;
      case 'annulée':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Aide à obtenir une couleur de badge en fonction de la priorité de la tâche.
  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'haute':
        return Colors.red[700]!;
      case 'moyenne':
        return Colors.orange[700]!;
      case 'basse':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF5C6BC0)], // Dégradé de couleurs cohérent.
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Bouton d'ajout unique déplacé dans l'AppBar pour une meilleure visibilité.
          IconButton(
            icon: const Icon(Icons.add_task, color: Colors.white, size: 28), // Icône plus spécifique.
            tooltip: 'Ajouter une nouvelle tâche',
            onPressed: () => _navigateToAddEditTask(),
          ),
          const SizedBox(width: 10), // Un peu d'espace.
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher une tâche',
                hintText: 'Titre, statut, priorité...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          // Réinitialise le terme de recherche dans le ViewModel.
                          Provider.of<TaskViewModel>(context, listen: false).setSearchTerm('');
                          FocusScope.of(context).unfocus(); // Cache le clavier après avoir vidé le champ.
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Consumer<TaskViewModel>(
              builder: (context, taskViewModel, child) {
                // Affiche un indicateur de chargement si les données sont en cours de récupération.
                if (taskViewModel.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 10),
                        Text('Chargement des tâches...', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                      ],
                    ),
                  );
                }

                // Affiche un message d'erreur si une erreur s'est produite lors de la récupération des données.
                if (taskViewModel.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[400], size: 60),
                          const SizedBox(height: 15),
                          Text(
                            'Erreur: ${taskViewModel.errorMessage!}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700], fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Veuillez vérifier votre connexion internet et réessayer.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 15),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => taskViewModel.fetchTasks(), // Bouton pour réessayer.
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Affiche un message si aucune tâche n'est trouvée (après filtrage ou initialement).
                if (taskViewModel.tasks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist, color: Colors.grey[400], size: 80),
                          const SizedBox(height: 20),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Aucune tâche trouvée pour "${_searchController.text}".'
                                : 'Aucune tâche n\'a été créée. Appuyez sur le bouton "+" pour en ajouter une.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          // Affiche un bouton "Ajouter une tâche" si la liste est vide et qu'il n'y a pas de recherche active.
                          if (_searchController.text.isEmpty) ...[
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _navigateToAddEditTask(),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Ajouter une Tâche', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                // Affiche la liste des tâches filtrées.
                return ListView.builder(
                  itemCount: taskViewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskViewModel.tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 6.0, // Ombre plus prononcée.
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Bords plus arrondis.
                      child: InkWell(
                        // `InkWell` pour un effet de "tap" visuel sur la carte.
                        onTap: () async {
                          // Navigue vers l'écran de détail de la tâche.
                          final bool? result = await Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => TaskDetailScreen(task: task),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                          // Si la tâche a été modifiée depuis l'écran de détail, rafraîchit la liste.
                          if (result == true) {
                            if (mounted) {
                              taskViewModel.fetchTasks();
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.titreTache,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            // Barre le titre si la tâche est "Terminée".
                                            decoration: task.statut == 'Terminée' ? TextDecoration.lineThrough : null,
                                            color: task.statut == 'Terminée' ? Colors.grey : Colors.black87,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Badge de statut stylisé.
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(task.statut).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      task.statut ?? 'Inconnu',
                                      style: TextStyle(
                                        color: _getStatusColor(task.statut),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Affiche la description si elle existe.
                              if (task.detailsDescription != null && task.detailsDescription!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    task.detailsDescription!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const Divider(height: 20, thickness: 1), // Séparateur visuel.
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Début: ${task.formattedDateHeureDebut}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                      ),
                                      // Affiche la date de fin si elle existe.
                                      if (task.formattedDateHeureFin != null && task.formattedDateHeureFin!.isNotEmpty)
                                        Text(
                                          'Fin: ${task.formattedDateHeureFin!}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                  // Badge de priorité stylisé.
                                  if (task.priorite != null && task.priorite!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(task.priorite).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Text(
                                        'Priorité: ${task.priorite!}',
                                        style: TextStyle(
                                          color: _getPriorityColor(task.priorite),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                      tooltip: 'Modifier la tâche',
                                      onPressed: () => _navigateToAddEditTask(task: task),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Supprimer la tâche',
                                      onPressed: () => _confirmAndDeleteTask(task.id, task.titreTache),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Le Floating Action Button est supprimé d'ici car l'icône d'ajout est dans l'AppBar.
      // Si vous souhaitez le conserver en plus du bouton de l'AppBar, vous pouvez le décommenter.
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditTask(),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Ajouter une tâche',
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      */
    );
  }
}