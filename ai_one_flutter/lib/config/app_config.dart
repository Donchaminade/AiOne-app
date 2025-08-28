// lib/config/app_config.dart

class AppConfig {
  // Configuration d'environnement
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  static const bool isProduction = environment == 'production';
  static const bool isDevelopment = environment == 'development';
  
  // Configuration de l'API
  static const String apiSecretKey = String.fromEnvironment(
    'API_SECRET_KEY',
    defaultValue: '67b26cd3db50a9fcf76c17f70db248442898f4e4d89436b470b38d86ba40156e84010a138cd81671cbfb600ecb42bc1043b00e5759da597cb76393abd8de31f1'
  );
  
  // URLs de base selon l'environnement
  static String get baseUrl {
    if (isProduction) {
      return 'https://your-production-domain.com/api_php/api';
    } else {
      // Pour le développement, détection automatique de la plateforme
      return _getDevelopmentUrl();
    }
  }
  
  static String _getDevelopmentUrl() {
    // URL pour émulateur Android (10.0.2.2 pointe vers localhost de la machine hôte)
    const androidEmulatorUrl = 'http://10.0.2.2/ai-one/api_php/api';
    
    // URL pour émulateur iOS et web (localhost)
    const iosSimulatorUrl = 'http://localhost/ai-one/api_php/api';
    
    // URL pour appareil physique (remplacez par l'IP de votre machine)
    const physicalDeviceUrl = 'http://192.168.1.100/ai-one/api_php/api';
    
    // Tentative de détection automatique (par défaut émulateur Android)
    return androidEmulatorUrl;
  }
  
  // Configuration des timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Configuration de pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
  
  // Configuration du cache
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxCacheSize = 100; // nombre d'éléments max en cache
  
  // Configuration de sécurité
  static const String appName = 'AiOne';
  static const String appVersion = '1.0.0';
  
  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-Name': appName,
    'X-App-Version': appVersion,
    if (apiSecretKey.isNotEmpty) 'X-API-Key': apiSecretKey,
  };
  
  // Configuration de debug
  static bool get enableApiLogging => isDevelopment;
  static bool get enableErrorReporting => isProduction;
  
  // Méthodes utilitaires
  static String getEndpoint(String path) {
    return '$baseUrl/$path';
  }
  
  static bool get isValidConfig {
    return baseUrl.isNotEmpty && 
           (isProduction ? apiSecretKey != '67b26cd3db50a9fcf76c17f70db248442898f4e4d89436b470b38d86ba40156e84010a138cd81671cbfb600ecb42bc1043b00e5759da597cb76393abd8de31f1'
: true);
  }
  
  // Configuration des messages d'erreur
  static const Map<String, String> errorMessages = {
    'network_error': 'Problème de connexion réseau. Vérifiez votre connexion internet.',
    'server_error': 'Erreur du serveur. Veuillez réessayer plus tard.',
    'timeout_error': 'La requête a pris trop de temps. Vérifiez votre connexion.',
    'parse_error': 'Erreur de format des données reçues.',
    'unauthorized': 'Accès non autorisé. Vérifiez vos identifiants.',
    'not_found': 'Ressource non trouvée.',
    'validation_error': 'Données invalides.',
    'unknown_error': 'Une erreur inconnue s\'est produite.',
  };
  
  // Debug info
  static Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'baseUrl': baseUrl,
    'hasApiKey': apiSecretKey.isNotEmpty,
    'isValidConfig': isValidConfig,
    'defaultPageSize': defaultPageSize,
    'connectTimeout': connectTimeout.inSeconds,
  };
}

// Classe pour les constantes d'endpoints
class ApiEndpoints {
  static const String contacts = 'contacts.php';
  static const String credentials = 'credentials.php';
  static const String notes = 'notes.php';
  static const String tasks = 'tasks.php';
  
  // Méthodes utilitaires pour construire les URLs
  static String contactById(int id) => '$contacts?id=$id';
  static String credentialById(int id) => '$credentials?id=$id';
  static String noteById(int id) => '$notes?id=$id';
  static String taskById(int id) => '$tasks?id=$id';
  
  static String contactsWithParams({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (orderBy != null) params['orderBy'] = orderBy;
    if (orderDir != null) params['orderDir'] = orderDir;
    
    if (params.isEmpty) return contacts;
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '$contacts?$queryString';
  }
  
  static String credentialsWithParams({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (orderBy != null) params['orderBy'] = orderBy;
    if (orderDir != null) params['orderDir'] = orderDir;
    
    if (params.isEmpty) return credentials;
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '$credentials?$queryString';
  }
  
  static String notesWithParams({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (orderBy != null) params['orderBy'] = orderBy;
    if (orderDir != null) params['orderDir'] = orderDir;
    
    if (params.isEmpty) return notes;
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '$notes?$queryString';
  }
  
  static String tasksWithParams({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (orderBy != null) params['orderBy'] = orderBy;
    if (orderDir != null) params['orderDir'] = orderDir;
    
    if (params.isEmpty) return tasks;
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '$tasks?$queryString';
  }
}
