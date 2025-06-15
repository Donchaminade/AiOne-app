// ai_one_flutter/lib/screens/notes/note_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/note.dart';
import 'package:ai_one_flutter/viewmodels/note_viewmodel.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titreController;
  late TextEditingController _sousTitreController;
  late TextEditingController _contenuController;
  late TextEditingController _dossiersController;
  late TextEditingController _tagsLabelsController;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.note?.titre ?? '');
    _sousTitreController = TextEditingController(text: widget.note?.sousTitre ?? '');
    _contenuController = TextEditingController(text: widget.note?.contenu ?? '');
    _dossiersController = TextEditingController(text: widget.note?.dossiers ?? '');
    _tagsLabelsController = TextEditingController(text: widget.note?.tagsLabels ?? '');
  }

  @override
  void dispose() {
    _titreController.dispose();
    _sousTitreController.dispose();
    _contenuController.dispose();
    _dossiersController.dispose();
    _tagsLabelsController.dispose();
    super.dispose();
  }

  // Helper pour les champs de texte (réutilisé et adapté des écrans précédents)
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Espacement vertical entre les champs
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.secondary) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // Coins arrondis pour les champs
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0), // Bordure plus épaisse au focus
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0), // Bordure par défaut
          ),
          filled: true, // Remplissage du champ
          fillColor: Colors.white, // Couleur de remplissage
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0), // Padding interne
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Masquer le clavier
      FocusScope.of(context).unfocus();

      final noteViewModel = Provider.of<NoteViewModel>(context, listen: false);

      final noteData = {
        'titre': _titreController.text,
        'sous_titre': _sousTitreController.text.isNotEmpty ? _sousTitreController.text : null,
        'contenu': _contenuController.text.isNotEmpty ? _contenuController.text : null,
        'dossiers': _dossiersController.text.isNotEmpty ? _dossiersController.text : null,
        'tags_labels': _tagsLabelsController.text.isNotEmpty ? _tagsLabelsController.text : null,
      };

      bool success = false;
      String message = '';

      if (widget.note == null) {
        // Mode Ajout
        success = await noteViewModel.addNote(noteData);
        message = success ? 'Note ajoutée avec succès !' : (noteViewModel.errorMessage ?? 'Erreur lors de l\'ajout.');
      } else {
        // Mode Modification
        success = await noteViewModel.updateNote(widget.note!.id, noteData);
        message = success ? 'Note mise à jour avec succès !' : (noteViewModel.errorMessage ?? 'Erreur lors de la mise à jour.');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.of(context).pop(true); // Retourne true pour indiquer un succès
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, noteViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.note == null ? 'Ajouter une Note' : 'Modifier la Note'),
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF5C6BC0)], // Correspond au dégradé des autres écrans
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: noteViewModel.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(
                        widget.note == null ? 'Ajout en cours...' : 'Mise à jour en cours...',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0), // Padding plus généreux
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // Champ Titre
                        _buildTextField(
                          controller: _titreController,
                          labelText: 'Titre *',
                          prefixIcon: Icons.title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le titre de la note';
                            }
                            return null;
                          },
                        ),
                        // Champ Sous-titre
                        _buildTextField(
                          controller: _sousTitreController,
                          labelText: 'Sous-titre',
                          prefixIcon: Icons.short_text,
                        ),
                        // Champ Contenu
                        _buildTextField(
                          controller: _contenuController,
                          labelText: 'Contenu',
                          prefixIcon: Icons.description,
                          maxLines: 8, // Plus de lignes pour le contenu
                          keyboardType: TextInputType.multiline,
                        ),
                        // Champ Dossiers
                        _buildTextField(
                          controller: _dossiersController,
                          labelText: 'Dossiers (ex: Travail, Personnel)',
                          prefixIcon: Icons.folder_open,
                        ),
                        // Champ Tags / Labels
                        _buildTextField(
                          controller: _tagsLabelsController,
                          labelText: 'Tags / Labels (ex: Urgent, Idée)',
                          prefixIcon: Icons.tag,
                        ),
                        const SizedBox(height: 30),

                        // Bouton de soumission stylisé
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: Icon(
                              widget.note == null ? Icons.add_circle_outline : Icons.save,
                              color: Colors.white,
                            ),
                            label: Text(
                              widget.note == null ? 'Ajouter la Note' : 'Mettre à Jour',
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}