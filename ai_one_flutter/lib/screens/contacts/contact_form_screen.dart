// ai_one_flutter/lib/screens/contacts/contact_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // NOUVEL IMPORT
import 'package:ai_one_flutter/models/contact.dart';
import 'package:ai_one_flutter/viewmodels/contact_viewmodel.dart'; // NOUVEL IMPORT
import 'package:intl/intl.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  const ContactFormScreen({super.key, this.contact});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomCompletController;
  late TextEditingController _professionController;
  late TextEditingController _numeroTelephoneController;
  late TextEditingController _adresseEmailController;
  late TextEditingController _adresseController;
  late TextEditingController _entrepriseOrganisationController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _tagsLabelsController;
  late TextEditingController _notesSpecifiquesController;

  DateTime? _selectedDateNaissance;

  // L'état de chargement est maintenant géré par le ViewModel
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomCompletController = TextEditingController(text: widget.contact?.nomComplet ?? '');
    _professionController = TextEditingController(text: widget.contact?.profession ?? '');
    _numeroTelephoneController = TextEditingController(text: widget.contact?.numeroTelephone ?? '');
    _adresseEmailController = TextEditingController(text: widget.contact?.adresseEmail ?? '');
    _adresseController = TextEditingController(text: widget.contact?.adresse ?? '');
    _entrepriseOrganisationController = TextEditingController(text: widget.contact?.entrepriseOrganisation ?? '');
    _tagsLabelsController = TextEditingController(text: widget.contact?.tagsLabels ?? '');
    _notesSpecifiquesController = TextEditingController(text: widget.contact?.notesSpecifiques ?? '');

    _selectedDateNaissance = widget.contact?.dateNaissance;
    _dateNaissanceController = TextEditingController(
      text: _selectedDateNaissance != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDateNaissance!)
          : '',
    );
  }

  @override
  void dispose() {
    _nomCompletController.dispose();
    _professionController.dispose();
    _numeroTelephoneController.dispose();
    _adresseEmailController.dispose();
    _adresseController.dispose();
    _entrepriseOrganisationController.dispose();
    _dateNaissanceController.dispose();
    _tagsLabelsController.dispose();
    _notesSpecifiquesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateNaissance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateNaissance ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateNaissance) {
      setState(() {
        _selectedDateNaissance = picked;
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Pas besoin de setState(_isLoading = true) ici, le ViewModel le gère
      final contactViewModel = Provider.of<ContactViewModel>(context, listen: false);

      final contactData = {
        'nom_complet': _nomCompletController.text,
        'profession': _professionController.text.isNotEmpty ? _professionController.text : null,
        'numero_telephone': _numeroTelephoneController.text.isNotEmpty ? _numeroTelephoneController.text : null,
        'adresse_email': _adresseEmailController.text,
        'adresse': _adresseController.text.isNotEmpty ? _adresseController.text : null,
        'entreprise_organisation': _entrepriseOrganisationController.text.isNotEmpty ? _entrepriseOrganisationController.text : null,
        'date_naissance': _selectedDateNaissance?.toIso8601String().split('T')[0],
        'tags_labels': _tagsLabelsController.text.isNotEmpty ? _tagsLabelsController.text : null,
        'notes_specifiques': _notesSpecifiquesController.text.isNotEmpty ? _notesSpecifiquesController.text : null,
      };

      bool success = false;
      if (widget.contact == null) {
        success = await contactViewModel.addContact(contactData);
      } else {
        success = await contactViewModel.updateContact(widget.contact!.id, contactData);
      }

      if (success) {
        Navigator.of(context).pop(true); // Retourne true pour indiquer un succès
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(contactViewModel.errorMessage ?? 'Une erreur est survenue.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utilise Consumer pour réagir à l'état de chargement du ViewModel
    return Consumer<ContactViewModel>(
      builder: (context, contactViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.contact == null ? 'Ajouter un Contact' : 'Modifier le Contact'),
          ),
          body: contactViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _nomCompletController,
                          decoration: const InputDecoration(labelText: 'Nom Complet *'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom complet';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _professionController,
                          decoration: const InputDecoration(labelText: 'Profession'),
                        ),
                        TextFormField(
                          controller: _numeroTelephoneController,
                          decoration: const InputDecoration(labelText: 'Numéro de Téléphone'),
                          keyboardType: TextInputType.phone,
                        ),
                        TextFormField(
                          controller: _adresseEmailController,
                          decoration: const InputDecoration(labelText: 'Adresse Email *'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une adresse email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Veuillez entrer une adresse email valide';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _adresseController,
                          decoration: const InputDecoration(labelText: 'Adresse Postale'),
                        ),
                        TextFormField(
                          controller: _entrepriseOrganisationController,
                          decoration: const InputDecoration(labelText: 'Entreprise / Organisation'),
                        ),
                        TextFormField(
                          controller: _dateNaissanceController,
                          decoration: InputDecoration(
                            labelText: 'Date de Naissance',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDateNaissance(context),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDateNaissance(context),
                        ),
                        TextFormField(
                          controller: _tagsLabelsController,
                          decoration: const InputDecoration(labelText: 'Tags / Labels (ex: Famille, Travail)'),
                        ),
                        TextFormField(
                          controller: _notesSpecifiquesController,
                          decoration: const InputDecoration(labelText: 'Notes Spécifiques'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(widget.contact == null ? 'Ajouter' : 'Mettre à Jour'),
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