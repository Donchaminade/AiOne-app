import 'package:intl/intl.dart';

class Note {
  final int id;
  final String titre;
  final String? sousTitre;
  final String? contenu;
  final String? dossiers;
  final String? tagsLabels;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.titre,
    this.sousTitre,
    this.contenu,
    this.dossiers,
    this.tagsLabels,
    required this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      titre: json['titre'] as String,
      sousTitre: json['sous_titre'] as String?,
      contenu: json['contenu'] as String?,
      dossiers: json['dossiers'] as String?,
      tagsLabels: json['tags_labels'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'sous_titre': sousTitre,
      'contenu': contenu,
      'dossiers': dossiers,
      'tags_labels': tagsLabels,
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
}