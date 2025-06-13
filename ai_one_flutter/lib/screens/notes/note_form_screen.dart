// ai_one_flutter/lib/screens/notes/note_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/note.dart';
// ApiService toujours pour les appels directs
import 'package:ai_one_flutter/viewmodels/note_viewmodel.dart'; // NOUVEL IMPORT

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final noteViewModel = Provider.of<NoteViewModel>(context, listen: false);

      final noteData = {
        'titre': _titreController.text,
        'sous_titre': _sousTitreController.text.isNotEmpty ? _sousTitreController.text : null,
        'contenu': _contenuController.text.isNotEmpty ? _contenuController.text : null,
        'dossiers': _dossiersController.text.isNotEmpty ? _dossiersController.text : null,
        'tags_labels': _tagsLabelsController.text.isNotEmpty ? _tagsLabelsController.text : null,
      };

      bool success = false;
      if (widget.note == null) {
        success = await noteViewModel.addNote(noteData);
      } else {
        success = await noteViewModel.updateNote(widget.note!.id, noteData);
      }

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(noteViewModel.errorMessage ?? 'Une erreur est survenue.')),
        );
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
          ),
          body: noteViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _titreController,
                          decoration: const InputDecoration(labelText: 'Titre *'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le titre de la note';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _sousTitreController,
                          decoration: const InputDecoration(labelText: 'Sous-titre'),
                        ),
                        TextFormField(
                          controller: _contenuController,
                          decoration: const InputDecoration(labelText: 'Contenu'),
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                        ),
                        TextFormField(
                          controller: _dossiersController,
                          decoration: const InputDecoration(labelText: 'Dossiers (ex: Travail, Personnel)'),
                        ),
                        TextFormField(
                          controller: _tagsLabelsController,
                          decoration: const InputDecoration(labelText: 'Tags / Labels (ex: Urgent, Idée)'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(widget.note == null ? 'Ajouter' : 'Mettre à Jour'),
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