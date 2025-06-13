// ai_one_flutter/lib/screens/credentials/credential_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/credential.dart';
import 'package:ai_one_flutter/viewmodels/credential_viewmodel.dart'; // NOUVEL IMPORT

class CredentialFormScreen extends StatefulWidget {
  final Credential? credential;

  const CredentialFormScreen({super.key, this.credential});

  @override
  State<CredentialFormScreen> createState() => _CredentialFormScreenState();
}

class _CredentialFormScreenState extends State<CredentialFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomSiteCompteController;
  late TextEditingController _nomUtilisateurEmailController;
  late TextEditingController _motDePasseController;
  late TextEditingController _autresInfosController;
  late TextEditingController _categorieController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nomSiteCompteController = TextEditingController(text: widget.credential?.nomSiteCompte ?? '');
    _nomUtilisateurEmailController = TextEditingController(text: widget.credential?.nomUtilisateurEmail ?? '');
    _motDePasseController = TextEditingController(text: ''); // Ne pas pré-remplir le mot de passe
    _autresInfosController = TextEditingController(text: widget.credential?.autresInfosChiffre ?? '');
    _categorieController = TextEditingController(text: widget.credential?.categorie ?? '');
  }

  @override
  void dispose() {
    _nomSiteCompteController.dispose();
    _nomUtilisateurEmailController.dispose();
    _motDePasseController.dispose();
    _autresInfosController.dispose();
    _categorieController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final credentialViewModel = Provider.of<CredentialViewModel>(context, listen: false);

      final Map<String, dynamic> credentialData = {
        'nom_site_compte': _nomSiteCompteController.text,
        'nom_utilisateur_email': _nomUtilisateurEmailController.text,
        'autres_infos_chiffre': _autresInfosController.text.isNotEmpty ? _autresInfosController.text : null,
        'categorie': _categorieController.text.isNotEmpty ? _categorieController.text : null,
      };

      // N'ajoutez le mot de passe que s'il est non vide
      if (_motDePasseController.text.isNotEmpty) {
        credentialData['mot_de_passe_chiffre'] = _motDePasseController.text;
      } else if (widget.credential != null) {
        // En mode édition, si le champ mot de passe est vide, cela signifie "ne pas changer"
        // Nous nous assurons de ne pas envoyer un champ "mot_de_passe_chiffre" vide ou null
        // si l'API est conçue pour maintenir l'ancien mot de passe dans ce cas.
        // Sinon, si votre API requiert un mot de passe même à l'update, vous devrez le gérer.
        // Pour FastAPI avec PUT/PATCH, si le champ est omis, il ne sera pas mis à jour.
      }


      bool success = false;
      if (widget.credential == null) {
        success = await credentialViewModel.addCredential(credentialData);
      } else {
        success = await credentialViewModel.updateCredential(widget.credential!.id, credentialData);
      }

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(credentialViewModel.errorMessage ?? 'Une erreur est survenue.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CredentialViewModel>(
      builder: (context, credentialViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.credential == null ? 'Ajouter un Identifiant' : 'Modifier l\'Identifiant'),
          ),
          body: credentialViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _nomSiteCompteController,
                          decoration: const InputDecoration(labelText: 'Nom du site / Compte *'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom du site/compte';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _nomUtilisateurEmailController,
                          decoration: const InputDecoration(labelText: 'Nom d\'utilisateur / Email *'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom d\'utilisateur ou l\'email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _motDePasseController,
                          decoration: InputDecoration(
                            labelText: 'Mot de Passe (laissez vide pour ne pas modifier)',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          // En mode ajout, le mot de passe est obligatoire
                          validator: (value) {
                            if (widget.credential == null && (value == null || value.isEmpty)) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _autresInfosController,
                          decoration: const InputDecoration(labelText: 'Autres Informations Chiffrées'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                        TextFormField(
                          controller: _categorieController,
                          decoration: const InputDecoration(labelText: 'Catégorie (ex: Réseaux Sociaux, Banque)'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(widget.credential == null ? 'Ajouter' : 'Mettre à Jour'),
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