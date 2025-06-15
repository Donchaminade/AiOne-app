// ai_one_flutter/lib/screens/notes/note_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour Clipboard
import 'package:ai_one_flutter/models/note.dart';
import 'package:ai_one_flutter/screens/notes/note_form_screen.dart'; // Pour la navigation vers l'édition

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  // Méthode pour copier du texte dans le presse-papiers
  Future<void> _copyToClipboard(BuildContext context, String text, String fieldName) async {
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

  // Méthode pour naviguer vers l'écran d'édition
  void _navigateToEditNote(BuildContext context) async {
    final bool? result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NoteFormScreen(note: widget.note),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    // Si une modification a eu lieu, recharger les données (ou pop et recharger dans la liste)
    if (result == true) {
      if (context.mounted) {
        // Dans un cas réel, vous rafraîchiriez les données de la note ici
        // ou vous rechargeriez la liste via un ViewModel si c'était un Provider.
        // Pour cet exemple simple, nous allons simplement revenir en arrière.
        Navigator.of(context).pop(true); // Signale à l'écran précédent qu'une mise à jour a eu lieu
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.titre),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Modifier la note',
            onPressed: () => _navigateToEditNote(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte pour le titre et le sous-titre
            _buildInfoCard(
              context,
              icon: Icons.title,
              title: 'Titre',
              value: widget.note.titre,
              isCopyable: true,
            ),
            _buildInfoCard(
              context,
              icon: Icons.short_text,
              title: 'Sous-titre',
              value: widget.note.sousTitre,
              isCopyable: true,
            ),

            // Carte pour le contenu principal
            _buildInfoCard(
              context,
              icon: Icons.description,
              title: 'Contenu',
              value: widget.note.contenu,
              isCopyable: true,
              isContent: true, // Pour un style spécifique au contenu
            ),

            // Cartes pour les dossiers et les tags
            _buildInfoCard(
              context,
              icon: Icons.folder_open,
              title: 'Dossiers',
              value: widget.note.dossiers,
              isCopyable: true,
            ),
            _buildInfoCard(
              context,
              icon: Icons.tag,
              title: 'Tags',
              value: widget.note.tagsLabels,
              isCopyable: true,
            ),

            // Cartes pour les dates de création/modification
            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              title: 'Créée le',
              value: widget.note.formattedCreatedAt,
            ),
            _buildInfoCard(
              context,
              icon: Icons.update,
              title: 'Dernière modification',
              value: widget.note.formattedUpdatedAt,
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
        bool isContent = false, // Pour styliser spécifiquement le champ de contenu
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
          crossAxisAlignment: isContent ? CrossAxisAlignment.start : CrossAxisAlignment.center, // Alignement différent pour le contenu
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
                  SizedBox(height: isContent ? 8 : 5), // Plus d'espace pour le contenu
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      fontSize: 17,
                      // Style spécifique pour le contenu si c'est une longue description
                      height: isContent ? 1.5 : null,
                    ),
                    textAlign: isContent ? TextAlign.justify : TextAlign.start,
                  ),
                ],
              ),
            ),
            if (isCopyable)
              IconButton(
                icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.secondary),
                tooltip: 'Copier $title',
                onPressed: () => _copyToClipboard(context, value, title),
              ),
          ],
        ),
      ),
    );
  }
}