// ai_one_flutter/lib/screens/notes/note_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/note.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.title, 'Titre:', note.titre),
            _buildDetailRow(Icons.short_text, 'Sous-titre:', note.sousTitre),
            _buildDetailRow(Icons.description, 'Contenu:', note.contenu),
            _buildDetailRow(Icons.folder, 'Dossiers:', note.dossiers),
            _buildDetailRow(Icons.tag, 'Tags:', note.tagsLabels),
            _buildDetailRow(Icons.calendar_today, 'Créée le:', note.formattedCreatedAt),
            _buildDetailRow(Icons.update, 'Modifiée le:', note.formattedUpdatedAt),
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
}