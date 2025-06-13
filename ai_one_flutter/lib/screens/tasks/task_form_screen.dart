// ai_one_flutter/lib/screens/tasks/task_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/task.dart';
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart'; // NOUVEL IMPORT
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
  final List<String> _statuts = ['À faire', 'En cours', 'Terminé', 'Annulé'];

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

  Future<void> _selectDateTime(BuildContext context, {required bool isStart}) async {
    DateTime initialDate = (isStart ? _selectedDateHeureDebut : _selectedDateHeureFin) ?? DateTime.now();
    TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
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
      final taskViewModel = Provider.of<TaskViewModel>(context, listen: false);

      final taskData = {
        'titre_tache': _titreTacheController.text,
        'date_heure_debut': _selectedDateHeureDebut?.toIso8601String(),
        'date_heure_fin': _selectedDateHeureFin?.toIso8601String(),
        'details_description': _detailsDescriptionController.text.isNotEmpty ? _detailsDescriptionController.text : null,
        'priorite': _selectedPriorite,
        'statut': _selectedStatut,
      };

      bool success = false;
      if (widget.task == null) {
        success = await taskViewModel.addTask(taskData);
      } else {
        success = await taskViewModel.updateTask(widget.task!.id, taskData);
      }

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(taskViewModel.errorMessage ?? 'Une erreur est survenue.')),
        );
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
          ),
          body: taskViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _titreTacheController,
                          decoration: const InputDecoration(labelText: 'Titre de la Tâche *'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le titre de la tâche';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _dateHeureDebutController,
                          decoration: InputDecoration(
                            labelText: 'Date et Heure de Début *',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDateTime(context, isStart: true),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDateTime(context, isStart: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une date et heure de début';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _dateHeureFinController,
                          decoration: InputDecoration(
                            labelText: 'Date et Heure de Fin (optionnel)',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDateTime(context, isStart: false),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDateTime(context, isStart: false),
                        ),
                        TextFormField(
                          controller: _detailsDescriptionController,
                          decoration: const InputDecoration(labelText: 'Détails / Description'),
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedPriorite,
                          decoration: const InputDecoration(labelText: 'Priorité'),
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
                        DropdownButtonFormField<String>(
                          value: _selectedStatut,
                          decoration: const InputDecoration(labelText: 'Statut'),
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(widget.task == null ? 'Ajouter' : 'Mettre à Jour'),
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