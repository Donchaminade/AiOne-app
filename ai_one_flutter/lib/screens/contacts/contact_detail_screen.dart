// ai_one_flutter/lib/screens/contacts/contact_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/contact.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.nomComplet),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.person, 'Nom Complet:', contact.nomComplet),
            _buildDetailRow(Icons.work, 'Profession:', contact.profession),
            _buildDetailRow(Icons.phone, 'Téléphone:', contact.numeroTelephone),
            _buildDetailRow(Icons.email, 'Email:', contact.adresseEmail),
            _buildDetailRow(Icons.location_on, 'Adresse:', contact.adresse),
            _buildDetailRow(Icons.business, 'Entreprise:', contact.entrepriseOrganisation),
            _buildDetailRow(Icons.cake, 'Date de Naissance:', contact.formattedDateNaissance),
            _buildDetailRow(Icons.label, 'Tags:', contact.tagsLabels),
            _buildDetailRow(Icons.notes, 'Notes:', contact.notesSpecifiques),
            _buildDetailRow(Icons.calendar_today, 'Créé le:', contact.formattedCreatedAt),
            _buildDetailRow(Icons.update, 'Modifié le:', contact.formattedUpdatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Ne rien afficher si la valeur est vide
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
}