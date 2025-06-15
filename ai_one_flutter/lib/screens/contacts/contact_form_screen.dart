// ai_one_flutter/lib/screens/contacts/contact_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/contact.dart';
import 'package:ai_one_flutter/viewmodels/contact_viewmodel.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les données existantes si en mode édition
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
    // Libération des contrôleurs pour éviter les fuites de mémoire
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

  // Fonction pour afficher le sélecteur de date de naissance
  Future<void> _selectDateNaissance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateNaissance ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Personnalisation du thème du DatePicker
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // Couleur principale de votre thème
              onPrimary: Colors.white, // Couleur du texte sur la couleur principale
              onSurface: Colors.black87, // Couleur du texte sur la surface
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Couleur des boutons
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateNaissance) {
      setState(() {
        _selectedDateNaissance = picked;
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Fonction de soumission du formulaire
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Masquer le clavier
      FocusScope.of(context).unfocus();

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
      String message = '';

      if (widget.contact == null) {
        // Mode Ajout
        success = await contactViewModel.addContact(contactData);
        message = success ? 'Contact ajouté avec succès !' : (contactViewModel.errorMessage ?? 'Erreur lors de l\'ajout.');
      } else {
        // Mode Modification
        success = await contactViewModel.updateContact(widget.contact!.id, contactData);
        message = success ? 'Contact mis à jour avec succès !' : (contactViewModel.errorMessage ?? 'Erreur lors de la mise à jour.');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red, // Feedback visuel couleur
          ),
        );
        if (success) {
          Navigator.of(context).pop(true); // Retourne true pour indiquer un succès et rafraîchir la liste
        }
      }
    }
  }

  // Helper pour les champs de texte
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Espacement vertical entre les champs
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
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

  @override
  Widget build(BuildContext context) {
    // Utilise Consumer pour réagir à l'état de chargement du ViewModel
    return Consumer<ContactViewModel>(
      builder: (context, contactViewModel, child) {
        return Scaffold(
          // AppBar avec dégradé et titre dynamique
          appBar: AppBar(
            title: Text(widget.contact == null ? 'Ajouter un Contact' : 'Modifier le Contact'),
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF5C6BC0)], // Correspond au dégradé de l'AppBar de ContactDetailScreen
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Affichage d'un indicateur de chargement ou du formulaire
          body: contactViewModel.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(
                        widget.contact == null ? 'Ajout en cours...' : 'Mise à jour en cours...',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0), // Padding général plus généreux
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // Champ Nom Complet
                        _buildTextField(
                          controller: _nomCompletController,
                          labelText: 'Nom Complet *',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom complet';
                            }
                            return null;
                          },
                        ),
                        // Champ Profession
                        _buildTextField(
                          controller: _professionController,
                          labelText: 'Profession',
                          prefixIcon: Icons.work,
                        ),
                        // Champ Numéro de Téléphone
                        _buildTextField(
                          controller: _numeroTelephoneController,
                          labelText: 'Numéro de Téléphone',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        // Champ Adresse Email
                        _buildTextField(
                          controller: _adresseEmailController,
                          labelText: 'Adresse Email *',
                          prefixIcon: Icons.email,
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
                        // Champ Adresse Postale
                        _buildTextField(
                          controller: _adresseController,
                          labelText: 'Adresse Postale',
                          prefixIcon: Icons.location_on,
                        ),
                        // Champ Entreprise / Organisation
                        _buildTextField(
                          controller: _entrepriseOrganisationController,
                          labelText: 'Entreprise / Organisation',
                          prefixIcon: Icons.business,
                        ),
                        // Champ Date de Naissance (avec sélecteur de date)
                        _buildTextField(
                          controller: _dateNaissanceController,
                          labelText: 'Date de Naissance',
                          prefixIcon: Icons.calendar_today,
                          readOnly: true,
                          onTap: () => _selectDateNaissance(context),
                        ),
                        // Champ Tags / Labels
                        _buildTextField(
                          controller: _tagsLabelsController,
                          labelText: 'Tags / Labels (ex: Famille, Travail)',
                          prefixIcon: Icons.label,
                        ),
                        // Champ Notes Spécifiques (multi-lignes)
                        _buildTextField(
                          controller: _notesSpecifiquesController,
                          labelText: 'Notes Spécifiques',
                          prefixIcon: Icons.notes,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 30), // Espacement avant le bouton

                        // Bouton de soumission stylisé
                        SizedBox(
                          width: double.infinity, // Bouton pleine largeur
                          height: 55, // Hauteur du bouton
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: Icon(
                              widget.contact == null ? Icons.add : Icons.save,
                              color: Colors.white,
                            ),
                            label: Text(
                              widget.contact == null ? 'Ajouter le Contact' : 'Mettre à Jour',
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary, // Couleur du thème
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0), // Coins arrondis
                              ),
                              elevation: 5, // Ombre
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