// ai_one_flutter/lib/screens/credentials/credential_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/credential.dart';
import 'package:ai_one_flutter/viewmodels/credential_viewmodel.dart';

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

  bool _obscurePassword = true; // Pour la visibilité du mot de passe

  @override
  void initState() {
    super.initState();
    _nomSiteCompteController = TextEditingController(text: widget.credential?.nomSiteCompte ?? '');
    _nomUtilisateurEmailController = TextEditingController(text: widget.credential?.nomUtilisateurEmail ?? '');
    // IMPORTANT : Ne pas pré-remplir le mot de passe pour des raisons de sécurité
    // Le champ doit être vide pour que l'utilisateur entre un nouveau mot de passe
    // ou le laisse vide s'il ne veut pas le modifier.
    _motDePasseController = TextEditingController(text: '');
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

  // Helper pour les champs de texte (réutilisé du ContactFormScreen)
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
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
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.secondary) : null,
          suffixIcon: suffixIcon,
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

      final credentialViewModel = Provider.of<CredentialViewModel>(context, listen: false);

      final Map<String, dynamic> credentialData = {
        'nom_site_compte': _nomSiteCompteController.text,
        'nom_utilisateur_email': _nomUtilisateurEmailController.text,
        'autres_infos_chiffre': _autresInfosController.text.isNotEmpty ? _autresInfosController.text : null,
        'categorie': _categorieController.text.isNotEmpty ? _categorieController.text : null,
      };

      // Ajoutez le mot de passe seulement s'il a été renseigné.
      // Si le champ est vide en mode édition, l'API ne devrait pas le modifier.
      if (_motDePasseController.text.isNotEmpty) {
        credentialData['mot_de_passe_chiffre'] = _motDePasseController.text;
      }

      bool success = false;
      String message = '';

      if (widget.credential == null) {
        // Mode Ajout
        success = await credentialViewModel.addCredential(credentialData);
        message = success ? 'Identifiant ajouté avec succès !' : (credentialViewModel.errorMessage ?? 'Erreur lors de l\'ajout.');
      } else {
        // Mode Modification
        success = await credentialViewModel.updateCredential(widget.credential!.id, credentialData);
        message = success ? 'Identifiant mis à jour avec succès !' : (credentialViewModel.errorMessage ?? 'Erreur lors de la mise à jour.');
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
    return Consumer<CredentialViewModel>(
      builder: (context, credentialViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.credential == null ? 'Ajouter un Identifiant' : 'Modifier l\'Identifiant'),
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
          body: credentialViewModel.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(
                        widget.credential == null ? 'Ajout en cours...' : 'Mise à jour en cours...',
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
                        // Champ Nom du site / Compte
                        _buildTextField(
                          controller: _nomSiteCompteController,
                          labelText: 'Nom du site / Compte *',
                          prefixIcon: Icons.web_asset,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom du site ou du compte';
                            }
                            return null;
                          },
                        ),
                        // Champ Nom d'utilisateur / Email
                        _buildTextField(
                          controller: _nomUtilisateurEmailController,
                          labelText: 'Nom d\'utilisateur / Email *',
                          prefixIcon: Icons.account_circle,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom d\'utilisateur ou l\'email';
                            }
                            return null;
                          },
                        ),
                        // Champ Mot de Passe
                        _buildTextField(
                          controller: _motDePasseController,
                          labelText: widget.credential == null
                              ? 'Mot de Passe *' // Obligatoire à l'ajout
                              : 'Mot de Passe (laissez vide pour ne pas modifier)', // Optionnel à la modif
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (widget.credential == null && (value == null || value.isEmpty)) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            return null;
                          },
                        ),
                        // Champ Autres Informations Chiffrées
                        _buildTextField(
                          controller: _autresInfosController,
                          labelText: 'Autres Informations Chiffrées',
                          prefixIcon: Icons.info_outline,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                        // Champ Catégorie
                        _buildTextField(
                          controller: _categorieController,
                          labelText: 'Catégorie (ex: Réseaux Sociaux, Banque)',
                          prefixIcon: Icons.category,
                        ),
                        const SizedBox(height: 30),

                        // Bouton de soumission stylisé
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: Icon(
                              widget.credential == null ? Icons.add_circle_outline : Icons.save,
                              color: Colors.white,
                            ),
                            label: Text(
                              widget.credential == null ? 'Ajouter l\'Identifiant' : 'Mettre à Jour',
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