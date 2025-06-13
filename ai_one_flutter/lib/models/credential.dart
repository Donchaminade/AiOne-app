import 'package:intl/intl.dart';

class Credential {
  final int id;
  final String nomSiteCompte;
  final String nomUtilisateurEmail;
  final String? motDePasseChiffre; // Le mot de passe déchiffré lors de la récupération d'un seul item
  final String? autresInfosChiffre; // Les autres infos déchiffrées
  final String? categorie;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Credential({
    required this.id,
    required this.nomSiteCompte,
    required this.nomUtilisateurEmail,
    this.motDePasseChiffre,
    this.autresInfosChiffre,
    this.categorie,
    required this.createdAt,
    this.updatedAt,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'] as int,
      nomSiteCompte: json['nom_site_compte'] as String,
      nomUtilisateurEmail: json['nom_utilisateur_email'] as String,
      motDePasseChiffre: json['mot_de_passe_chiffre'] as String?,
      autresInfosChiffre: json['autres_infos_chiffre'] as String?,
      categorie: json['categorie'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_site_compte': nomSiteCompte,
      'nom_utilisateur_email': nomUtilisateurEmail,
      'mot_de_passe_chiffre': motDePasseChiffre,
      'autres_infos_chiffre': autresInfosChiffre,
      'categorie': categorie,
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