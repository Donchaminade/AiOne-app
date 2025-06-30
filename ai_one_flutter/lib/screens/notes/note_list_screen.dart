// ai_one_flutter/lib/screens/notes/note_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/note.dart';
import 'package:ai_one_flutter/screens/notes/note_form_screen.dart';
import 'package:ai_one_flutter/screens/notes/note_detail_screen.dart';
import 'package:ai_one_flutter/viewmodels/note_viewmodel.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Exécuter fetchNotes après que le widget ait été construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteViewModel>(context, listen: false).fetchNotes();
    });
    // Ajouter un listener pour la barre de recherche
    _searchController.addListener(() {
      Provider.of<NoteViewModel>(
        context,
        listen: false,
      ).setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      // Le listener doit être une fonction nommée si vous voulez la retirer spécifiquement.
      // Dans ce cas, puisque nous utilisons une lambda, la meilleure pratique est de ne rien passer
      // à removeListener, ou de recréer la lambda et espérer qu'elle corresponde.
      // Pour des raisons de simplicité et si le listener est simple, ceci est souvent toléré.
    });
    _searchController.dispose();
    super.dispose();
  }

  // Navigation vers l'écran d'ajout/édition de note
  void _navigateToAddEditNote({Note? note}) async {
    final bool? result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NoteFormScreen(note: note),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (result == true) {
      // Recharger les notes après une création/édition réussie
      Provider.of<NoteViewModel>(context, listen: false).fetchNotes();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opération terminée avec succès.'),
            backgroundColor: Colors.green, // Couleur pour le succès
          ),
        );
      }
    }
  }

  // Confirmation et suppression d'une note
  Future<void> _confirmAndDeleteNote(int id, String titre) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          'Confirmer la suppression',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la note "$titre" ? Cette action est irréversible.',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Couleur rouge pour supprimer
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final noteViewModel = Provider.of<NoteViewModel>(context, listen: false);
      final success = await noteViewModel.deleteNote(id);
      if (context.mounted) {
        if (success) {
          noteViewModel.fetchNotes(); // Recharger les notes après suppression
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note "$titre" supprimée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                noteViewModel.errorMessage ??
                    'Erreur lors de la suppression de la note "$titre".',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF673AB7),
                Color(0xFF5C6BC0),
              ], // Correspond au dégradé des autres écrans
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Ajouter une nouvelle note',
            onPressed: () => _navigateToAddEditNote(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<NoteViewModel>(
        builder: (context, noteViewModel, child) {
          return Column(
            children: [
              // Barre de recherche stylisée
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher une note',
                    hintText: 'Titre, contenu, dossier, tag...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              noteViewModel.setSearchTerm('');
                              FocusScope.of(
                                context,
                              ).unfocus(); // Masquer le clavier
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 15.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: noteViewModel.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Chargement des notes...',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : noteViewModel.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            noteViewModel.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : noteViewModel.notes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? 'Aucune note trouvée pour "${_searchController.text}".'
                                : 'Aucune note n\'a été trouvée. Appuyez sur le bouton "+" pour en ajouter une.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: noteViewModel.notes.length,
                        itemBuilder: (context, index) {
                          final note = noteViewModel.notes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: InkWell(
                              onTap: () async {
                                // Naviguer vers les détails, et rafraîchir si des changements ont eu lieu
                                final bool? result = await Navigator.of(context)
                                    .push(
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => NoteDetailScreen(note: note),
                                        transitionsBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                        transitionDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                      ),
                                    );
                                if (result == true) {
                                  noteViewModel
                                      .fetchNotes(); // Recharger la liste si la note a été modifiée/supprimée via l'écran de détail
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.note,
                                      size: 30,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note.titre,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepPurple,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            note.sousTitre != null &&
                                                    note.sousTitre!.isNotEmpty
                                                ? note.sousTitre!
                                                : (note.contenu != null &&
                                                          note
                                                              .contenu!
                                                              .isNotEmpty
                                                      ? note.contenu!
                                                      : 'Aucun contenu'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                            maxLines:
                                                2, // Affiche plus de contenu/sous-titre
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (note.tagsLabels != null &&
                                              note.tagsLabels!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tags: ${note.tagsLabels}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.blueGrey,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                          tooltip: 'Modifier la note',
                                          onPressed: () =>
                                              _navigateToAddEditNote(
                                                note: note,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Supprimer la note',
                                          onPressed: () =>
                                              _confirmAndDeleteNote(
                                                note.id,
                                                note.titre,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
