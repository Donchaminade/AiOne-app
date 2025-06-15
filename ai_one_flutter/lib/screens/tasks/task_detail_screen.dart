// ai_one_flutter/lib/screens/tasks/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour Clipboard
import 'package:ai_one_flutter/models/task.dart';
import 'package:ai_one_flutter/screens/tasks/task_form_screen.dart'; // Pour la navigation vers l'édition

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
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
  void _navigateToEditTask(BuildContext context) async {
    final bool? result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TaskFormScreen(task: widget.task),
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
        // Dans un cas réel, vous rafraîchiriez les données de la tâche ici
        // ou vous rechargeriez la liste via un ViewModel si c'était un Provider.
        // Pour cet exemple simple, nous allons simplement revenir en arrière.
        Navigator.of(context).pop(true); // Signale à l'écran précédent qu'une mise à jour a eu lieu
      }
    }
  }

  // Helper pour obtenir la couleur du statut
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'terminée':
        return Colors.green;
      case 'en cours':
        return Colors.orange;
      case 'en attente':
        return Colors.blue;
      case 'annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper pour obtenir la couleur de la priorité
  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'haute':
        return Colors.red;
      case 'moyenne':
        return Colors.orange;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.titreTache),
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
            tooltip: 'Modifier la tâche',
            onPressed: () => _navigateToEditTask(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte pour le titre de la tâche
            _buildInfoCard(
              context,
              icon: Icons.task_alt,
              title: 'Titre de la tâche',
              value: widget.task.titreTache,
              isCopyable: true,
            ),

            // Carte pour les dates/heures de début et fin
            _buildInfoCard(
              context,
              icon: Icons.play_arrow,
              title: 'Début',
              value: widget.task.formattedDateHeureDebut,
              isCopyable: true,
            ),
            _buildInfoCard(
              context,
              icon: Icons.flag,
              title: 'Fin',
              value: widget.task.formattedDateHeureFin,
              isCopyable: true,
            ),

            // Carte pour les détails/description
            _buildInfoCard(
              context,
              icon: Icons.description,
              title: 'Détails',
              value: widget.task.detailsDescription,
              isCopyable: true,
              isContent: true, // Pour un style spécifique au contenu
            ),

            // Carte pour la priorité avec couleur
            _buildInfoCard(
              context,
              icon: Icons.priority_high,
              title: 'Priorité',
              value: widget.task.priorite,
              isCopyable: true,
              valueColor: _getPriorityColor(widget.task.priorite),
            ),

            // Carte pour le statut avec couleur
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              title: 'Statut',
              value: widget.task.statut,
              isCopyable: true,
              valueColor: _getStatusColor(widget.task.statut),
            ),

            // Cartes pour les dates de création/modification
            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              title: 'Créée le',
              value: widget.task.formattedCreatedAt,
            ),
            _buildInfoCard(
              context,
              icon: Icons.update,
              title: 'Dernière modification',
              value: widget.task.formattedUpdatedAt,
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
        Color? valueColor, // Pour appliquer une couleur spécifique à la valeur
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
          crossAxisAlignment: isContent ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                  SizedBox(height: isContent ? 8 : 5),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: valueColor ?? Colors.black87, // Applique la couleur si fournie
                      fontSize: 17,
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