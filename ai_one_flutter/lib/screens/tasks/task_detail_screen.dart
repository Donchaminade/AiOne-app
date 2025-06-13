// ai_one_flutter/lib/screens/tasks/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ai_one_flutter/models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.titreTache),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.task_alt, 'Titre:', task.titreTache),
            _buildDetailRow(Icons.play_arrow, 'Début:', task.formattedDateHeureDebut),
            _buildDetailRow(Icons.flag, 'Fin:', task.formattedDateHeureFin),
            _buildDetailRow(Icons.description, 'Détails:', task.detailsDescription),
            _buildDetailRow(Icons.priority_high, 'Priorité:', task.priorite),
            _buildDetailRow(Icons.info_outline, 'Statut:', task.statut),
            _buildDetailRow(Icons.calendar_today, 'Créée le:', task.formattedCreatedAt),
            _buildDetailRow(Icons.update, 'Modifiée le:', task.formattedUpdatedAt),
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