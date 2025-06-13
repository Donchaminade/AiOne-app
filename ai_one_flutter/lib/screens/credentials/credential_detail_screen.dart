// ai_one_flutter/lib/screens/credentials/credential_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/credential.dart';
// import 'package:flutter/services.dart'; // Pour copier dans le presse-papiers

class CredentialDetailScreen extends StatelessWidget {
  final Credential credential;

  const CredentialDetailScreen({super.key, required this.credential});

  // Future<void> _copyToClipboard(BuildContext context, String text) async {
  //   await Clipboard.setData(ClipboardData(text: text));
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Copié dans le presse-papiers !')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(credential.nomSiteCompte),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.web, 'Site / Compte:', credential.nomSiteCompte),
            _buildDetailRow(Icons.person, 'Nom d\'utilisateur / Email:', credential.nomUtilisateurEmail),
            // Pour le mot de passe, un affichage sécurisé ou une option de déchiffrement après authentification
            // est RECOMMANDÉ. Pour l'instant, on n'affiche pas le mot de passe clair ici.
            _buildPasswordRow(context, credential.motDePasseChiffre), // Exemple comment l'intégrer
            _buildDetailRow(Icons.info, 'Autres Infos Chiffrées:', credential.autresInfosChiffre),
            _buildDetailRow(Icons.category, 'Catégorie:', credential.categorie),
            _buildDetailRow(Icons.calendar_today, 'Créé le:', credential.formattedCreatedAt),
            _buildDetailRow(Icons.update, 'Modifié le:', credential.formattedUpdatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Exemple d'une ligne pour le mot de passe (vous devrez implémenter la logique de déchiffrement sécurisée)
  
  Widget _buildPasswordRow(BuildContext context, String? encryptedPassword) {
    if (encryptedPassword == null || encryptedPassword.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.vpn_key, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mot de Passe:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Ici, vous auriez un bouton pour "Afficher le mot de passe"
                // qui déclencherait une authentification locale (biométrie, PIN)
                // puis déchiffrerait et afficherait le mot de passe temporairement.
                Text(
                  '*********** (Cliquable pour afficher)', // Ou un bouton
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                // Exemple de bouton pour copier (sans afficher le clair)
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copier le mot de passe'),
                  onPressed: () {
                    // Ici, vous devrez d'abord déchiffrer puis copier
                    // Pour l'instant, on ne copie pas le texte chiffré directement
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité de copie sécurisée à implémenter')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}