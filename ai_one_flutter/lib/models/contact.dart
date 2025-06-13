// Pour @required ou pour debugPrint si vous voulez
import 'package:intl/intl.dart'; // Pour formater les dates, assurez-vous d'ajouter intl à pubspec.yaml

// Ajoutez intl: ^0.18.1 dans dev_dependencies: ou dependencies: de votre pubspec.yaml
// Et lancez flutter pub get

class Contact {
  final int id;
  final String nomComplet;
  final String? profession;
  final String? numeroTelephone;
  final String adresseEmail;
  final String? adresse;
  final String? entrepriseOrganisation;
  final DateTime? dateNaissance;
  final String? tagsLabels;
  final String? notesSpecifiques;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Contact({
    required this.id,
    required this.nomComplet,
    this.profession,
    this.numeroTelephone,
    required this.adresseEmail,
    this.adresse,
    this.entrepriseOrganisation,
    this.dateNaissance,
    this.tagsLabels,
    this.notesSpecifiques,
    required this.createdAt,
    this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int,
      nomComplet: json['nom_complet'] as String,
      profession: json['profession'] as String?,
      numeroTelephone: json['numero_telephone'] as String?,
      adresseEmail: json['adresse_email'] as String,
      adresse: json['adresse'] as String?,
      entrepriseOrganisation: json['entreprise_organisation'] as String?,
      dateNaissance: json['date_naissance'] != null
          ? DateTime.parse(json['date_naissance'] as String)
          : null,
      tagsLabels: json['tags_labels'] as String?,
      notesSpecifiques: json['notes_specifiques'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_complet': nomComplet,
      'profession': profession,
      'numero_telephone': numeroTelephone,
      'adresse_email': adresseEmail,
      'adresse': adresse,
      'entreprise_organisation': entrepriseOrganisation,
      'date_naissance': dateNaissance?.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'tags_labels': tagsLabels,
      'notes_specifiques': notesSpecifiques,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Pour l'affichage convivial
  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }
  String? get formattedUpdatedAt {
    return updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt!) : null;
  }
  String? get formattedDateNaissance {
    return dateNaissance != null ? DateFormat('dd/MM/yyyy').format(dateNaissance!) : null;
  }
}