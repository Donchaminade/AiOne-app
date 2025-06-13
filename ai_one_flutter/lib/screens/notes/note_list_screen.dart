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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteViewModel>(context, listen: false).fetchNotes();
    });
    _searchController.addListener(() {
      Provider.of<NoteViewModel>(context, listen: false).setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddEditNote({Note? note}) async {
    final bool? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteFormScreen(note: note),
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opération terminée avec succès.')),
      );
    }
  }

  Future<void> _confirmAndDeleteNote(int id, String titre) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la note "$titre" ?'),
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
      final success = await Provider.of<NoteViewModel>(context, listen: false).deleteNote(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note "$titre" supprimée avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de la note "$titre".')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, noteViewModel, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher une note',
                  hintText: 'Entrez un titre, contenu, etc.',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            noteViewModel.setSearchTerm('');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: noteViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : noteViewModel.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              noteViewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : noteViewModel.notes.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? 'Aucune note trouvée pour "${_searchController.text}".'
                                    : 'Aucune note trouvée. Appuyez sur "+" pour en ajouter une.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: noteViewModel.notes.length,
                              itemBuilder: (context, index) {
                                final note = noteViewModel.notes[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: ListTile(
                                    leading: const Icon(Icons.note),
                                    title: Text(note.titre),
                                    subtitle: Text(
                                      note.sousTitre != null && note.sousTitre!.isNotEmpty
                                          ? note.sousTitre!
                                          : (note.contenu != null && note.contenu!.isNotEmpty ? note.contenu! : ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _navigateToAddEditNote(note: note),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _confirmAndDeleteNote(note.id, note.titre),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => NoteDetailScreen(note: note),
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