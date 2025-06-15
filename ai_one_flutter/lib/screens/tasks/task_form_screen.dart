// ai_one_flutter/lib/screens/tasks/task_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/task.dart';
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart';
import 'package:intl/intl.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titreTacheController;
  late TextEditingController _dateHeureDebutController;
  late TextEditingController _dateHeureFinController;
  late TextEditingController _detailsDescriptionController;

  DateTime? _selectedDateHeureDebut;
  DateTime? _selectedDateHeureFin;

  String? _selectedPriorite;
  String? _selectedStatut;

  final List<String> _priorites = ['Basse', 'Moyenne', 'Haute'];
  final List<String> _statuts = ['À faire', 'En cours', 'Terminée', 'Annulée'];

  @override
  void initState() {
    super.initState();
    _titreTacheController = TextEditingController(text: widget.task?.titreTache ?? '');
    _detailsDescriptionController = TextEditingController(text: widget.task?.detailsDescription ?? '');

    _selectedPriorite = widget.task?.priorite;
    _selectedStatut = widget.task?.statut;

    _selectedDateHeureDebut = widget.task?.dateHeureDebut;
    _dateHeureDebutController = TextEditingController(
      text: _selectedDateHeureDebut != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateHeureDebut!)
          : '',
    );

    _selectedDateHeureFin = widget.task?.dateHeureFin;
    _dateHeureFinController = TextEditingController(
      text: _selectedDateHeureFin != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateHeureFin!)
          : '',
    );
  }

  @override
  void dispose() {
    _titreTacheController.dispose();
    _dateHeureDebutController.dispose();
    _dateHeureFinController.dispose();
    _detailsDescriptionController.dispose();
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
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onTap: onTap,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.secondary) : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, {required bool isStart}) async {
    DateTime initialDate = (isStart ? _selectedDateHeureDebut : _selectedDateHeureFin) ?? DateTime.now();
    TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // Couleur principale du calendrier
              onPrimary: Colors.white, // Couleur du texte sur la couleur principale
              onSurface: Colors.black87, // Couleur du texte sur la surface du calendrier
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary, // Couleur principale de l'heure
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStart) {
            _selectedDateHeureDebut = selectedDateTime;
            _dateHeureDebutController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime);
          } else {
            _selectedDateHeureFin = selectedDateTime;
            _dateHeureFinController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime);
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Masquer le clavier
      FocusScope.of(context).unfocus();

      final taskViewModel = Provider.of<TaskViewModel>(context, listen: false);

      // Validation des dates
      if (_selectedDateHeureDebut == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner une date et heure de début.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      if (_selectedDateHeureFin != null && _selectedDateHeureFin!.isBefore(_selectedDateHeureDebut!)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La date de fin ne peut pas être antérieure à la date de début.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final taskData = {
        'titre_tache': _titreTacheController.text,
        'date_heure_debut': _selectedDateHeureDebut?.toIso8601String(),
        'date_heure_fin': _selectedDateHeureFin?.toIso8601String(),
        'details_description': _detailsDescriptionController.text.isNotEmpty ? _detailsDescriptionController.text : null,
        'priorite': _selectedPriorite,
        'statut': _selectedStatut,
      };

      bool success = false;
      String message = '';

      if (widget.task == null) {
        // Mode Ajout
        success = await taskViewModel.addTask(taskData);
        message = success ? 'Tâche ajoutée avec succès !' : (taskViewModel.errorMessage ?? 'Erreur lors de l\'ajout.');
      } else {
        // Mode Modification
        success = await taskViewModel.updateTask(widget.task!.id, taskData);
        message = success ? 'Tâche mise à jour avec succès !' : (taskViewModel.errorMessage ?? 'Erreur lors de la mise à jour.');
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
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.task == null ? 'Ajouter une Tâche' : 'Modifier la Tâche'),
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
          body: taskViewModel.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(
                        widget.task == null ? 'Ajout en cours...' : 'Mise à jour en cours...',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // Champ Titre de la Tâche
                        _buildTextField(
                          controller: _titreTacheController,
                          labelText: 'Titre de la Tâche *',
                          prefixIcon: Icons.task_alt,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le titre de la tâche';
                            }
                            return null;
                          },
                        ),
                        // Champ Date et Heure de Début
                        _buildTextField(
                          controller: _dateHeureDebutController,
                          labelText: 'Date et Heure de Début *',
                          prefixIcon: Icons.play_arrow,
                          readOnly: true,
                          onTap: () => _selectDateTime(context, isStart: true),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, color: Colors.grey),
                            onPressed: () => _selectDateTime(context, isStart: true),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une date et heure de début';
                            }
                            return null;
                          },
                        ),
                        // Champ Date et Heure de Fin
                        _buildTextField(
                          controller: _dateHeureFinController,
                          labelText: 'Date et Heure de Fin (optionnel)',
                          prefixIcon: Icons.flag,
                          readOnly: true,
                          onTap: () => _selectDateTime(context, isStart: false),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, color: Colors.grey),
                            onPressed: () => _selectDateTime(context, isStart: false),
                          ),
                        ),
                        // Champ Détails / Description
                        _buildTextField(
                          controller: _detailsDescriptionController,
                          labelText: 'Détails / Description',
                          prefixIcon: Icons.description,
                          maxLines: 6, // Plus de lignes pour la description
                          keyboardType: TextInputType.multiline,
                        ),
                        // Dropdown Priorité
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriorite,
                            decoration: InputDecoration(
                              labelText: 'Priorité',
                              prefixIcon: Icon(Icons.priority_high, color: Theme.of(context).colorScheme.secondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                            ),
                            items: _priorites.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedPriorite = newValue;
                              });
                            },
                          ),
                        ),
                        // Dropdown Statut
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatut,
                            decoration: InputDecoration(
                              labelText: 'Statut',
                              prefixIcon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                            ),
                            items: _statuts.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedStatut = newValue;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Bouton de soumission stylisé
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: Icon(
                              widget.task == null ? Icons.add_circle_outline : Icons.save,
                              color: Colors.white,
                            ),
                            label: Text(
                              widget.task == null ? 'Ajouter la Tâche' : 'Mettre à Jour',
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