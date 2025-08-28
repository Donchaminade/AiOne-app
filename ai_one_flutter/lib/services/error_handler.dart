// lib/services/error_handler.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Types d'erreurs personnalisées
enum ApiErrorType {
  network,
  timeout,
  server,
  unauthorized,
  forbidden,
  notFound,
  validation,
  rateLimit,
  unknown,
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? errors;
  final dynamic originalError;

  ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiException(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Vérifie si l'erreur est récupérable
  bool get isRecoverable {
    switch (type) {
      case ApiErrorType.network:
      case ApiErrorType.timeout:
      case ApiErrorType.server:
        return true;
      case ApiErrorType.unauthorized:
      case ApiErrorType.forbidden:
      case ApiErrorType.notFound:
      case ApiErrorType.validation:
      case ApiErrorType.rateLimit:
      case ApiErrorType.unknown:
        return false;
    }
  }

  /// Vérifie si l'utilisateur peut réessayer
  bool get canRetry {
    switch (type) {
      case ApiErrorType.network:
      case ApiErrorType.timeout:
      case ApiErrorType.server:
        return true;
      case ApiErrorType.rateLimit:
        return true; // Après un délai
      case ApiErrorType.unauthorized:
      case ApiErrorType.forbidden:
      case ApiErrorType.notFound:
      case ApiErrorType.validation:
      case ApiErrorType.unknown:
        return false;
    }
  }
}

/// Service de gestion centralisée des erreurs
class ErrorHandler {
  /// Convertit une exception en ApiException
  static ApiException handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is SocketException) {
      return ApiException(
        type: ApiErrorType.network,
        message: AppConfig.errorMessages['network_error']!,
        originalError: error,
      );
    }

    if (error is HttpException) {
      return ApiException(
        type: ApiErrorType.server,
        message: AppConfig.errorMessages['server_error']!,
        originalError: error,
      );
    }

    if (error is FormatException) {
      return ApiException(
        type: ApiErrorType.unknown,
        message: AppConfig.errorMessages['parse_error']!,
        originalError: error,
      );
    }

    // Erreur inconnue
    return ApiException(
      type: ApiErrorType.unknown,
      message: error.toString().isNotEmpty 
          ? error.toString() 
          : AppConfig.errorMessages['unknown_error']!,
      originalError: error,
    );
  }

  /// Gère spécifiquement les erreurs Dio
  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          type: ApiErrorType.timeout,
          message: AppConfig.errorMessages['timeout_error']!,
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.connectionError:
        return ApiException(
          type: ApiErrorType.network,
          message: AppConfig.errorMessages['network_error']!,
          originalError: error,
        );

      case DioExceptionType.cancel:
        return ApiException(
          type: ApiErrorType.unknown,
          message: 'Requête annulée',
          originalError: error,
        );

      default:
        return ApiException(
          type: ApiErrorType.unknown,
          message: error.message ?? AppConfig.errorMessages['unknown_error']!,
          originalError: error,
        );
    }
  }

  /// Gère les erreurs de réponse HTTP
  static ApiException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    ApiErrorType type;
    String message;
    String? code;
    Map<String, dynamic>? errors;

    switch (statusCode) {
      case 400:
        type = ApiErrorType.validation;
        message = _extractErrorMessage(responseData) ?? 
                  AppConfig.errorMessages['validation_error']!;
        code = _extractErrorCode(responseData);
        errors = _extractValidationErrors(responseData);
        break;

      case 401:
        type = ApiErrorType.unauthorized;
        message = _extractErrorMessage(responseData) ?? 
                  AppConfig.errorMessages['unauthorized']!;
        code = _extractErrorCode(responseData);
        break;

      case 403:
        type = ApiErrorType.forbidden;
        message = _extractErrorMessage(responseData) ?? 
                  'Accès interdit';
        code = _extractErrorCode(responseData);
        break;

      case 404:
        type = ApiErrorType.notFound;
        message = _extractErrorMessage(responseData) ?? 
                  AppConfig.errorMessages['not_found']!;
        code = _extractErrorCode(responseData);
        break;

      case 409:
        type = ApiErrorType.validation;
        message = _extractErrorMessage(responseData) ?? 
                  'Conflit de données';
        code = _extractErrorCode(responseData);
        break;

      case 429:
        type = ApiErrorType.rateLimit;
        message = _extractErrorMessage(responseData) ?? 
                  'Trop de requêtes. Veuillez patienter.';
        code = _extractErrorCode(responseData);
        break;

      case 500:
      case 502:
      case 503:
      case 504:
        type = ApiErrorType.server;
        message = AppConfig.errorMessages['server_error']!;
        break;

      default:
        type = ApiErrorType.unknown;
        message = _extractErrorMessage(responseData) ?? 
                  'Erreur HTTP $statusCode';
    }

    return ApiException(
      type: type,
      message: message,
      statusCode: statusCode,
      code: code,
      errors: errors,
      originalError: error,
    );
  }

  /// Extrait le message d'erreur de la réponse
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] as String?;
    }
    if (responseData is String) {
      return responseData;
    }
    return null;
  }

  /// Extrait le code d'erreur de la réponse
  static String? _extractErrorCode(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['code'] as String?;
    }
    return null;
  }

  /// Extrait les erreurs de validation de la réponse
  static Map<String, dynamic>? _extractValidationErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('errors')) {
      return responseData['errors'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Formatage des erreurs de validation pour l'affichage
  static String formatValidationErrors(Map<String, dynamic> errors) {
    final messages = <String>[];
    
    errors.forEach((field, fieldErrors) {
      if (fieldErrors is List) {
        for (final error in fieldErrors) {
          messages.add('$field: $error');
        }
      } else if (fieldErrors is String) {
        messages.add('$field: $fieldErrors');
      }
    });
    
    return messages.join('\n');
  }

  /// Obtient un message d'erreur convivial
  static String getFriendlyMessage(ApiException exception) {
    switch (exception.type) {
      case ApiErrorType.network:
        return 'Problème de connexion. Vérifiez votre connexion internet.';
      
      case ApiErrorType.timeout:
        return 'La connexion a pris trop de temps. Réessayez.';
      
      case ApiErrorType.server:
        return 'Problème avec le serveur. Réessayez dans quelques instants.';
      
      case ApiErrorType.unauthorized:
        return 'Accès non autorisé. Vérifiez vos identifiants.';
      
      case ApiErrorType.forbidden:
        return 'Vous n\'avez pas l\'autorisation d\'accéder à cette ressource.';
      
      case ApiErrorType.notFound:
        return 'Ressource introuvable.';
      
      case ApiErrorType.validation:
        if (exception.errors != null) {
          return formatValidationErrors(exception.errors!);
        }
        return exception.message;
      
      case ApiErrorType.rateLimit:
        return 'Trop de requêtes. Patientez avant de réessayer.';
      
      case ApiErrorType.unknown:
        return exception.message.isNotEmpty 
            ? exception.message 
            : 'Une erreur inattendue s\'est produite.';
    }
  }

  /// Log l'erreur (pour le debugging ou le reporting)
  static void logError(ApiException exception, {String? context}) {
    if (AppConfig.enableApiLogging) {
      print('=== API ERROR ===');
      if (context != null) print('Context: $context');
      print('Type: ${exception.type}');
      print('Message: ${exception.message}');
      print('Status Code: ${exception.statusCode}');
      print('Code: ${exception.code}');
      print('Errors: ${exception.errors}');
      print('Original Error: ${exception.originalError}');
      print('================');
    }
  }

  /// Reporte l'erreur pour le monitoring (en production)
  static Future<void> reportError(ApiException exception, {String? context}) async {
    if (AppConfig.enableErrorReporting) {
      // Ici vous pourriez intégrer avec un service comme Sentry, Crashlytics, etc.
      // await crashlytics.recordError(exception, context);
      
      // Pour l'instant, on log simplement
      logError(exception, context: context);
    }
  }
}

/// Extension pour faciliter la gestion d'erreurs dans les widgets
extension ApiExceptionExtension on ApiException {
  /// Message convivial pour l'utilisateur
  String get friendlyMessage => ErrorHandler.getFriendlyMessage(this);
  
  /// Icône appropriée selon le type d'erreur
  String get iconName {
    switch (type) {
      case ApiErrorType.network:
        return 'wifi_off';
      case ApiErrorType.timeout:
        return 'access_time';
      case ApiErrorType.server:
        return 'error_outline';
      case ApiErrorType.unauthorized:
        return 'lock_outline';
      case ApiErrorType.forbidden:
        return 'block';
      case ApiErrorType.notFound:
        return 'search_off';
      case ApiErrorType.validation:
        return 'error';
      case ApiErrorType.rateLimit:
        return 'pause_circle_outline';
      case ApiErrorType.unknown:
        return 'help_outline';
    }
  }
}
