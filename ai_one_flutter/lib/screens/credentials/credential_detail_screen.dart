// ai_one_flutter/lib/screens/credentials/credential_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour Clipboard
import 'package:local_auth/local_auth.dart'; // Pour l'authentification biométrique
import 'package:ai_one_flutter/models/credential.dart';
import 'package:ai_one_flutter/screens/credentials/credential_form_screen.dart'; // Pour l'édition

class CredentialDetailScreen extends StatefulWidget {
  final Credential credential;

  const CredentialDetailScreen({super.key, required this.credential});

  @override
  State<CredentialDetailScreen> createState() => _CredentialDetailScreenState();
}

class _CredentialDetailScreenState extends State<CredentialDetailScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _showPassword = false;

  // Méthode pour copier du texte dans le presse-papiers
  Future<void> _copyToClipboard(
    BuildContext context,
    String text,
    String fieldName,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName copié dans le presse-papiers !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Authentification locale pour afficher ou copier le mot de passe
  Future<void> _authenticateAndShowPassword(BuildContext context) async {
    try {
      final bool canAuthenticate = await auth.canCheckBiometrics;
      if (!canAuthenticate) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Aucune méthode d\'authentification biométrique/locale configurée sur cet appareil.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason:
            'Veuillez vous authentifier pour afficher le mot de passe',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly:
              false, // Permet aussi le code PIN/motif/empreinte digitale si biométrie non dispo
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _showPassword = true; // Afficher le mot de passe
        });
        // Optionnel: masquer le mot de passe après un certain délai
        Future.delayed(const Duration(seconds: 15), () {
          if (mounted && _showPassword) {
            setState(() {
              _showPassword = false;
            });
          }
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentification annulée ou échouée.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Erreur d'authentification: ${e.message}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'authentification : ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Méthode pour naviguer vers l'écran d'édition
  void _navigateToEditCredential(BuildContext context) async {
    final bool? result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CredentialFormScreen(credential: widget.credential),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    // Si une modification a eu lieu, recharger les données (ou pop et recharger dans la liste)
    if (result == true) {
      if (context.mounted) {
        // Dans un cas réel, vous rafraîchiriez les données du credential ici
        // ou vous rechargeriez la liste via un ViewModel si c'était un Provider.
        // Pour cet exemple simple, nous allons simplement revenir en arrière.
        Navigator.of(
          context,
        ).pop(true); // Signale à l'écran précédent qu'une mise à jour a eu lieu
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.credential.nomSiteCompte),
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
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Modifier l\'identifiant',
            onPressed: () => _navigateToEditCredential(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte pour les informations principales
            _buildInfoCard(
              context,
              icon: Icons.web_asset,
              title: 'Site / Compte',
              value: widget.credential.nomSiteCompte,
              isCopyable: true,
            ),
            _buildInfoCard(
              context,
              icon: Icons.person,
              title: 'Nom d\'utilisateur / Email',
              value: widget.credential.nomUtilisateurEmail,
              isCopyable: true,
            ),

            // Carte spécifique pour le mot de passe avec authentification et copie
            _buildPasswordCard(context),

            // Carte pour les autres informations chiffrées
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              title: 'Autres Informations',
              value: widget.credential.autresInfosChiffre,
              isCopyable: true, // Peut être copié tel quel (chiffré)
            ),

            // Carte pour la catégorie
            _buildInfoCard(
              context,
              icon: Icons.category,
              title: 'Catégorie',
              value: widget.credential.categorie,
            ),

            // Cartes pour les dates de création/modification
            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              title: 'Créé le',
              value: widget.credential.formattedCreatedAt,
            ),
            _buildInfoCard(
              context,
              icon: Icons.update,
              title: 'Dernière modification',
              value: widget.credential.formattedUpdatedAt,
            ),
          ],
        ),
      ),
    );
  }

  // Widget générique pour construire une carte d'information
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String? value,
    bool isCopyable = false,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Ne rien afficher si la valeur est vide
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value, // Corrected: Use null-aware operator !
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            if (isCopyable)
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                tooltip: 'Copier $title',
                onPressed: () => _copyToClipboard(
                  context,
                  value,
                  title,
                ), // Corrected: Use null-aware operator !
              ),
          ],
        ),
      ),
    );
  }

  // Widget spécifique pour la carte du mot de passe
  Widget _buildPasswordCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 15),
                Text(
                  'Mot de Passe',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: _showPassword
                  ? Text(
                      widget.credential.motDePasseChiffre!, // Corrected line
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            letterSpacing: 1.2,
                          ),
                    )
                  : Text(
                      '••••••••••••',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 2.0,
                          ),
                    ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _authenticateAndShowPassword(context),
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      label: Text(
                        _showPassword
                            ? 'Masquer le mot de passe'
                            : 'Afficher le mot de passe',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showPassword
                            ? Colors.orange
                            : Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Pour la copie, nous devons aussi authentifier si le mot de passe n'est pas déjà affiché
                        if (!_showPassword) {
                          final bool didAuthenticate = await auth.authenticate(
                            localizedReason:
                                'Authentifiez-vous pour copier le mot de passe',
                            options: const AuthenticationOptions(
                              biometricOnly: false,
                            ),
                          );
                          if (!didAuthenticate) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Authentification annulée ou échouée.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }
                        }
                        if (context.mounted) {
                          _copyToClipboard(
                            context,
                            widget.credential.motDePasseChiffre!,
                            'Mot de passe',
                          ); // Corrected line
                        }
                      },
                      icon: const Icon(Icons.copy, color: Colors.white),
                      label: const Text(
                        'Copier le mot de passe',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
