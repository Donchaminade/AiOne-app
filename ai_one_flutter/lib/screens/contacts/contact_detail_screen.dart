// ai_one_flutter/lib/screens/contacts/contact_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/contact.dart';
import 'package:ai_one_flutter/screens/contacts/contact_form_screen.dart'; // Pour l'édition
import 'package:url_launcher/url_launcher.dart' as url_launcher;
//import 'package:url_launcher/url_launcher_string.dart'; // Pour les URL

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar stylisée avec un dégradé
      appBar: AppBar(
        title: Text(contact.nomComplet),
        // Style du texte du titre de l'AppBar
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Couleur des icônes de l'AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // Couleurs du dégradé (à harmoniser avec le thème général)
              colors: [
                Color(0xFF673AB7),
                Color(0xFF5C6BC0),
              ], // Violet profond vers Bleu-indigo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Bouton "Modifier" avec une icône blanche pour contraste sur le dégradé
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Modifier le contact',
            onPressed: () async {
              // Navigation vers l'écran de formulaire en mode édition
              final bool? result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ContactFormScreen(contact: contact),
                ),
              );
              // Si le contact a été modifié, on signale à la liste de rafraîchir.
              // 'context.mounted' est une bonne pratique pour éviter les erreurs après la suppression de l'widget.
              if (result == true) {
                if (context.mounted) {
                  Navigator.of(context).pop(
                    true,
                  ); // Signale à l'écran précédent (ContactListScreen) qu'il doit rafraîchir ses données.
                }
              }
            },
          ),
        ],
      ),
      // Corps de l'écran avec un défilement unique pour tous les détails
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 20.0,
        ), // Padding général plus généreux
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section d'en-tête pour le nom et la profession du contact
            _buildHeader(context), // Pass context
            const SizedBox(height: 25), // Espacement après l'en-tête
            // Section "Informations Personnelles"
            _buildInfoSection(
              context, // Pass context
              title: 'Informations Personnelles',
              children: [
                _buildDetailRow(
                  context,
                  Icons.person,
                  'Nom Complet',
                  contact.nomComplet,
                ), // Pass context
                _buildDetailRow(
                  context,
                  Icons.work,
                  'Profession',
                  contact.profession,
                ), // Pass context
                _buildDetailRow(
                  context,
                  Icons.cake,
                  'Date de Naissance',
                  contact.formattedDateNaissance,
                ), // Pass context
              ],
            ),
            const SizedBox(height: 20), // Espacement entre les sections
            // Section "Coordonnées" avec des actions interactives
            _buildInfoSection(
              context, // Pass context
              title: 'Coordonnées',
              children: [
                _buildDetailRow(
                  context,
                  Icons.phone,
                  'Téléphone',
                  contact.numeroTelephone,
                  onTap: () => _makePhoneCall(context, contact.numeroTelephone),
                ), // Pass context
                _buildDetailRow(
                  context,
                  Icons.email,
                  'Email',
                  contact.adresseEmail,
                  onTap: () => _sendEmail(context, contact.adresseEmail),
                ), // Pass context
                _buildDetailRow(
                  context,
                  Icons.location_on,
                  'Adresse',
                  contact.adresse,
                  onTap: () => _openMap(context, contact.adresse),
                ), // Pass context
              ],
            ),
            const SizedBox(height: 20),
            // Section "Informations Complémentaires"
            _buildInfoSection(
              context, // Pass context
              title: 'Informations Complémentaires',
              children: [
                _buildDetailRow(
                  context,
                  Icons.business,
                  'Entreprise',
                  contact.entrepriseOrganisation,
                ), // Pass context
                _buildDetailRow(
                  context,
                  Icons.label,
                  'Tags',
                  contact.tagsLabels,
                ), // Pass context
                _buildDetailRow(
                  context,
                  Icons.notes,
                  'Notes Spécifiques',
                  contact.notesSpecifiques,
                  isLongText: true,
                ), // Pass context
              ],
            ),
            const SizedBox(height: 20),
            // Section "Historique"
            _buildInfoSection(
              context, // Pass context
              title: 'Historique',
              children: [
                _buildDetailRow(
                  context,
                  Icons.calendar_today,
                  'Créé le',
                  contact.formattedCreatedAt,
                ), // Pass context
                _buildDetailRow(
                  context,
                  Icons.update,
                  'Modifié le',
                  contact.formattedUpdatedAt,
                ), // Pass context
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour l'en-tête de l'écran de détails du contact
  Widget _buildHeader(BuildContext context) {
    // Add BuildContext context
    return Center(
      child: Column(
        children: [
          // Avatar circulaire avec une icône ou une image de profil
          CircleAvatar(
            radius: 60, // Taille de l'avatar augmentée
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.15), // Couleur de fond subtile
            child: Icon(
              Icons.account_circle, // Icône par défaut si pas de photo
              size: 90, // Taille de l'icône augmentée
              color: Theme.of(
                context,
              ).colorScheme.primary, // Couleur de l'icône
            ),
          ),
          const SizedBox(height: 15),
          // Nom complet du contact
          Text(
            contact.nomComplet,
            style: const TextStyle(
              fontSize: 30, // Taille de police augmentée
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          // Profession, affichée seulement si elle existe
          if (contact.profession != null && contact.profession!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                contact.profession!,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontStyle:
                      FontStyle.italic, // Style italique pour la profession
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 15),
          // Séparateur visuel
          Divider(color: Colors.grey[300], thickness: 1),
        ],
      ),
    );
  }

  // Widget pour construire une section d'informations (ex: Coordonnées, Personnelles)
  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    // Add BuildContext context
    // Filtrer les enfants pour n'afficher que ceux qui contiennent des données
    final visibleChildren = children
        .where((widget) => widget is! SizedBox || (widget).height != 0)
        .toList();

    if (visibleChildren.isEmpty) {
      return const SizedBox.shrink(); // Masquer la section si elle est entièrement vide
    }

    return Card(
      elevation: 5.0, // Ombre plus prononcée pour un effet de profondeur
      margin: EdgeInsets
          .zero, // La marge est gérée par le SizedBox en dehors de la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ), // Coins plus arrondis
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding interne augmenté
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la section
            Text(
              title,
              style: TextStyle(
                fontSize: 22, // Taille du titre de section augmentée
                fontWeight: FontWeight.bold,
                color: Theme.of(context)
                    .colorScheme
                    .primary, // Couleur du thème pour les titres de section
              ),
            ),
            const Divider(
              height: 25,
              thickness: 2.0,
              color: Colors.grey,
            ), // Séparateur plus épais
            ...visibleChildren, // Afficher les lignes de détails
          ],
        ),
      ),
    );
  }

  // Widget pour construire une seule ligne de détail (ex: Téléphone, Email)
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value, {
    VoidCallback? onTap,
    bool isLongText = false,
  }) {
    // Add BuildContext context
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Ne rien afficher si la valeur est vide
    }

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ), // Padding vertical pour espacement
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 26,
          ), // Icône plus grande, couleur secondaire
          const SizedBox(width: 20), // Espacement entre l'icône et le texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label de la donnée (ex: "Téléphone:")
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600, // Semi-gras
                    fontSize: 16,
                    color: Colors.grey[700], // Couleur plus douce pour le label
                  ),
                ),
                const SizedBox(height: 6), // Espacement entre label et valeur
                // Valeur de la donnée
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ), // Taille de la valeur légèrement plus grande
                  maxLines: isLongText
                      ? null
                      : 1, // Permet aux notes d'avoir plusieurs lignes
                  overflow: isLongText
                      ? TextOverflow.clip
                      : TextOverflow.ellipsis, // Gestion du débordement
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Si une action onTap est définie, envelopper le contenu dans un InkWell pour un effet de ripple
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          10.0,
        ), // Rayon pour l'effet de ripple
        child: content,
      );
    } else {
      return content;
    }
  }

  // --- Fonctions d'action (Nécessitent le package url_launcher) ---
  // Pour activer ces fonctions, assurez-vous d'avoir 'url_launcher' dans pubspec.yaml
  // et décommentez l'import et les appels url_launcher.launchUrl.

  void _makePhoneCall(BuildContext context, String? phoneNumber) async {
    // Add BuildContext context
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await url_launcher.canLaunchUrl(phoneUri)) {
        await url_launcher.launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de passer cet appel.')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numéro de téléphone non disponible.')),
        );
      }
    }
  }

  void _sendEmail(BuildContext context, String? email) async {
    if (email != null && email.isNotEmpty) {
      final Uri emailUri = Uri(scheme: 'mailto', path: email);
      try {
        if (await url_launcher.canLaunchUrl(emailUri)) {
          await url_launcher.launchUrl(emailUri);
        } else {
          // Message plus spécifique si aucun client mail n'est disponible
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aucune application de messagerie disponible ou configurée.')),
            );
          }
        }
      } catch (e) {
        // Capture toute erreur lors du lancement de l'URL
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'envoi de l\'email: ${e.toString()}')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adresse email non disponible.')),
        );
      }
    }
  }

  /// Tente d'ouvrir l'adresse spécifiée dans Google Maps ou une application de carte.
  void _openMap(BuildContext context, String? address) async {
    if (address != null && address.isNotEmpty) {
      // Encodez l'adresse pour l'URL afin de gérer les espaces et caractères spéciaux
      final String encodedAddress = Uri.encodeComponent(address);

      // Schéma d'URI pour lancer Google Maps.
      // 'geo:0,0?q=' est universel et devrait fonctionner sur la plupart des plateformes.
      // 'https://maps.google.com/?q=' est une alternative web compatible.
      final Uri mapUri = Uri.parse('geo:0,0?q=$encodedAddress');
      final Uri webMapUri = Uri.parse('https://maps.google.com/?q=$encodedAddress');

      try {
        if (await url_launcher.canLaunchUrl(mapUri)) {
          await url_launcher.launchUrl(mapUri);
        } else if (await url_launcher.canLaunchUrl(webMapUri)) {
          // Fallback vers la version web si l'application native ne peut pas être lancée
          await url_launcher.launchUrl(webMapUri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible d\'ouvrir la carte. Aucune application ou service de carte disponible.')),
            );
          }
        }
      } catch (e) {
        // Capture toute erreur lors du lancement de l'URL
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ouverture de la carte: ${e.toString()}')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adresse non disponible.')),
        );
      }
    }
  }

}
