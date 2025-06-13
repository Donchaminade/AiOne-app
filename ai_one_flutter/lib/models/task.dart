import 'package:intl/intl.dart';

class Task {
  final int id;
  final String titreTache;
  final DateTime dateHeureDebut;
  final DateTime? dateHeureFin;
  final String? detailsDescription;
  final String? priorite; // 'Haute', 'Moyenne', 'Basse'
  final String? statut; // 'À faire', 'En cours', 'Terminé', 'Annulé'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.titreTache,
    required this.dateHeureDebut,
    this.dateHeureFin,
    this.detailsDescription,
    this.priorite,
    this.statut,
    required this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      titreTache: json['titre_tache'] as String,
      dateHeureDebut: DateTime.parse(json['date_heure_debut'] as String),
      dateHeureFin: json['date_heure_fin'] != null
          ? DateTime.parse(json['date_heure_fin'] as String)
          : null,
      detailsDescription: json['details_description'] as String?,
      priorite: json['priorite'] as String?,
      statut: json['statut'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre_tache': titreTache,
      'date_heure_debut': dateHeureDebut.toIso8601String(),
      'date_heure_fin': dateHeureFin?.toIso8601String(),
      'details_description': detailsDescription,
      'priorite': priorite,
      'statut': statut,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }
  String? get formattedUpdatedAt {
    return updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt!) : null;
  }
  String get formattedDateHeureDebut {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateHeureDebut);
  }
  String? get formattedDateHeureFin {
    return dateHeureFin != null ? DateFormat('dd/MM/yyyy HH:mm').format(dateHeureFin!) : null;
  }
}