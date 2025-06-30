import 'package:intl/intl.dart';

class Credential {
  final int id;
  final String nomSiteCompte;
  final String nomUtilisateurEmail;
  // motDePasseChiffre est utilisé pour l'envoi de données (création/maj)
  // Il ne sera JAMAIS reçu du backend pour des raisons de sécurité (le backend stocke un hash)
  final String? motDePasseChiffre;
  // autresInfosChiffre stocke les données en clair (pas de chiffrement côté PHP)
  final String? autresInfosChiffre;
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
      // Nous ne recevons PLUS le mot de passe du backend pour des raisons de sécurité.
      // Donc, pas besoin de le parser ici. Il sera null si non fourni, ce qui est le comportement attendu.
      motDePasseChiffre: null, // Toujours null lors de la lecture depuis l'API
      autresInfosChiffre: json['autres_infos_chiffre'] as String?, // Maintenant en clair, pas de décodage spécial
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
      // Incluez mot_de_passe_chiffre SEULEMENT si vous le définissez pour créer/mettre à jour
      // Le backend se chargera de le hacher.
      if (motDePasseChiffre != null) 'mot_de_passe_chiffre': motDePasseChiffre,
      'autres_infos_chiffre': autresInfosChiffre, // Envoyez-le en clair
      'categorie': categorie,
      // createdAt et updatedAt ne sont généralement pas envoyés lors de la création/mise à jour,
      // car ils sont générés par la base de données.
      // Si votre API s'attend à les recevoir, gardez-les, sinon ils peuvent être omis.
      // 'created_at': createdAt.toIso8601String(),
      // 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }
  String? get formattedUpdatedAt {
    return updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt!) : null;
  }
}