// lib/services/improved_api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/contact.dart';
import '../models/credential.dart';
import '../models/note.dart';
import '../models/task.dart';
import 'error_handler.dart';

/// Service API amélioré avec toutes les nouvelles fonctionnalités
class ImprovedApiService {
  late final Dio _dio;
  static ImprovedApiService? _instance;

  ImprovedApiService._internal() {
    _dio = Dio(_getBaseOptions());
    _setupInterceptors();
  }

  static ImprovedApiService get instance {
    _instance ??= ImprovedApiService._internal();
    return _instance!;
  }

  /// Configuration de base pour Dio
  BaseOptions _getBaseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: AppConfig.defaultHeaders,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
    );
  }

  /// Configuration des intercepteurs
  void _setupInterceptors() {
    // Intercepteur de logging pour le développement
    if (AppConfig.enableApiLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => print('[API] $obj'),
        ),
      );
    }

    // Intercepteur pour la gestion d'erreurs
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final apiError = ErrorHandler.handleError(error);
          ErrorHandler.logError(apiError, context: 'API Request');
          handler.next(error);
        },
      ),
    );

    // Intercepteur pour la retry logic (optionnel)
    _dio.interceptors.add(RetryInterceptor());
  }

  /// Méthode générique pour GET avec pagination
  Future<ApiResponse<List<T>>> getList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final params = <String, dynamic>{
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (orderBy != null) 'orderBy': orderBy,
        if (orderDir != null) 'orderDir': orderDir,
        ...?additionalParams,
      };

      final response = await _dio.get(endpoint, queryParameters: params);

      return _parseListResponse(response, fromJson);
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      return ApiResponse.error(
        message: apiError.message,
        code: apiError.code,
        errors: apiError.errors,
      );
    }
  }

  /// Méthode générique pour GET d'un élément unique
  Future<ApiResponse<T>> getOne<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(endpoint);
      return _parseItemResponse(response, fromJson);
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      return ApiResponse.error(
        message: apiError.message,
        code: apiError.code,
        errors: apiError.errors,
      );
    }
  }

  /// Méthode générique pour POST
  Future<ApiResponse<T?>> post<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);

      if (fromJson != null) {
        return _parseItemResponse(response, fromJson);
      } else {
        return _parseGenericResponse<T>(response);
      }
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      return ApiResponse.error(
        message: apiError.message,
        code: apiError.code,
        errors: apiError.errors,
      );
    }
  }

  /// Méthode générique pour PUT
  Future<ApiResponse<T?>> put<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);

      if (fromJson != null) {
        return _parseItemResponse(response, fromJson);
      } else {
        return _parseGenericResponse<T>(response);
      }
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      return ApiResponse.error(
        message: apiError.message,
        code: apiError.code,
        errors: apiError.errors,
      );
    }
  }

  /// Méthode générique pour DELETE
  Future<ApiResponse<void>> delete({required String endpoint}) async {
    try {
      await _dio.delete(endpoint);
      return ApiResponse.success(message: 'Suppression réussie');
    } catch (e) {
      final apiError = ErrorHandler.handleError(e);
      return ApiResponse.error(
        message: apiError.message,
        code: apiError.code,
        errors: apiError.errors,
      );
    }
  }

  /// Parse les réponses de liste avec pagination
  ApiResponse<List<T>> _parseListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final responseData = response.data as Map<String, dynamic>;

    if (responseData['success'] == true) {
      final data = responseData['data'] as List?;
      final items =
          data
              ?.map((item) => fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      return ApiResponse.success(
        data: items,
        message: responseData['message'],
        pagination: responseData['pagination'] != null
            ? PaginationMeta.fromJson(responseData['pagination'])
            : null,
        searchMeta: SearchMeta(
          search: responseData['search'],
          orderBy: responseData['orderBy'],
          orderDir: responseData['orderDir'],
        ),
      );
    } else {
      return ApiResponse.error(
        message: responseData['message'],
        code: responseData['code'],
        errors: responseData['errors']?.cast<String, dynamic>(),
      );
    }
  }

  /// Parse les réponses d'élément unique
  ApiResponse<T> _parseItemResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final responseData = response.data as Map<String, dynamic>;

    if (responseData['success'] == true) {
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data != null) {
        return ApiResponse.success(
          data: fromJson(data),
          message: responseData['message'],
        );
      } else {
        return ApiResponse.error(message: 'Aucune donnée reçue');
      }
    } else {
      return ApiResponse.error(
        message: responseData['message'],
        code: responseData['code'],
        errors: responseData['errors']?.cast<String, dynamic>(),
      );
    }
  }

  /// Parse les réponses génériques (pour POST/PUT sans retour d'objet)
  ApiResponse<T?> _parseGenericResponse<T>(Response response) {
    final responseData = response.data as Map<String, dynamic>;

    if (responseData['success'] == true) {
      return ApiResponse.success(message: responseData['message']);
    } else {
      return ApiResponse.error(
        message: responseData['message'],
        code: responseData['code'],
        errors: responseData['errors']?.cast<String, dynamic>(),
      );
    }
  }

  // === CONTACTS ===

  Future<ApiResponse<List<Contact>>> getContacts({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    return getList<Contact>(
      endpoint: ApiEndpoints.contacts,
      fromJson: (json) => Contact.fromJson(json),
      page: page,
      limit: limit,
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
    );
  }

  Future<ApiResponse<Contact>> getContact(int id) {
    return getOne<Contact>(
      endpoint: ApiEndpoints.contactById(id),
      fromJson: (json) => Contact.fromJson(json),
    );
  }

  Future<ApiResponse<void>> createContact(Map<String, dynamic> contactData) {
    return post<void>(endpoint: ApiEndpoints.contacts, data: contactData);
  }

  Future<ApiResponse<void>> updateContact(
    int id,
    Map<String, dynamic> contactData,
  ) {
    return put<void>(endpoint: ApiEndpoints.contactById(id), data: contactData);
  }

  Future<ApiResponse<void>> deleteContact(int id) {
    return delete(endpoint: ApiEndpoints.contactById(id));
  }

  // === CREDENTIALS ===

  Future<ApiResponse<List<Credential>>> getCredentials({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    return getList<Credential>(
      endpoint: ApiEndpoints.credentials,
      fromJson: (json) => Credential.fromJson(json),
      page: page,
      limit: limit,
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
    );
  }

  Future<ApiResponse<Credential>> getCredential(int id) {
    return getOne<Credential>(
      endpoint: ApiEndpoints.credentialById(id),
      fromJson: (json) => Credential.fromJson(json),
    );
  }

  Future<ApiResponse<void>> createCredential(
    Map<String, dynamic> credentialData,
  ) {
    return post<void>(endpoint: ApiEndpoints.credentials, data: credentialData);
  }

  Future<ApiResponse<void>> updateCredential(
    int id,
    Map<String, dynamic> credentialData,
  ) {
    return put<void>(
      endpoint: ApiEndpoints.credentialById(id),
      data: credentialData,
    );
  }

  Future<ApiResponse<void>> deleteCredential(int id) {
    return delete(endpoint: ApiEndpoints.credentialById(id));
  }

  // === NOTES ===

  Future<ApiResponse<List<Note>>> getNotes({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    return getList<Note>(
      endpoint: ApiEndpoints.notes,
      fromJson: (json) => Note.fromJson(json),
      page: page,
      limit: limit,
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
    );
  }

  Future<ApiResponse<Note>> getNote(int id) {
    return getOne<Note>(
      endpoint: ApiEndpoints.noteById(id),
      fromJson: (json) => Note.fromJson(json),
    );
  }

  Future<ApiResponse<void>> createNote(Map<String, dynamic> noteData) {
    return post<void>(endpoint: ApiEndpoints.notes, data: noteData);
  }

  Future<ApiResponse<void>> updateNote(int id, Map<String, dynamic> noteData) {
    return put<void>(endpoint: ApiEndpoints.noteById(id), data: noteData);
  }

  Future<ApiResponse<void>> deleteNote(int id) {
    return delete(endpoint: ApiEndpoints.noteById(id));
  }

  // === TASKS ===

  Future<ApiResponse<List<Task>>> getTasks({
    int? page,
    int? limit,
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    return getList<Task>(
      endpoint: ApiEndpoints.tasks,
      fromJson: (json) => Task.fromJson(json),
      page: page,
      limit: limit,
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
    );
  }

  Future<ApiResponse<Task>> getTask(int id) {
    return getOne<Task>(
      endpoint: ApiEndpoints.taskById(id),
      fromJson: (json) => Task.fromJson(json),
    );
  }

  Future<ApiResponse<void>> createTask(Map<String, dynamic> taskData) {
    return post<void>(endpoint: ApiEndpoints.tasks, data: taskData);
  }

  Future<ApiResponse<void>> updateTask(int id, Map<String, dynamic> taskData) {
    return put<void>(endpoint: ApiEndpoints.taskById(id), data: taskData);
  }

  Future<ApiResponse<void>> deleteTask(int id) {
    return delete(endpoint: ApiEndpoints.taskById(id));
  }

  // === UTILITY METHODS ===

  /// Teste la connectivité avec l'API
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get(
        '/test',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtient les informations de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'baseUrl': _dio.options.baseUrl,
      'connectTimeout': _dio.options.connectTimeout?.inSeconds,
      'headers': _dio.options.headers,
      'appConfig': AppConfig.debugInfo,
    };
  }
}

/// Intercepteur de retry automatique pour les erreurs réseau
class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    if (_shouldRetry(err) && _canRetry(requestOptions)) {
      final retryCount = (requestOptions.extra['retryCount'] as int?) ?? 0;

      if (retryCount < maxRetries) {
        requestOptions.extra['retryCount'] = retryCount + 1;

        // Délai avant retry
        await Future.delayed(retryDelay * (retryCount + 1));

        if (AppConfig.enableApiLogging) {
          print(
            '[RETRY] Tentative ${retryCount + 1}/$maxRetries pour ${requestOptions.path}',
          );
        }

        try {
          final dio = Dio();
          dio.options = err.requestOptions.copyWith();
          final response = await dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
          );
          handler.resolve(response);
        } catch (e) {
          super.onError(err, handler);
        }
      } else {
        super.onError(err, handler);
      }
    } else {
      super.onError(err, handler);
    }
  }

  bool _shouldRetry(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return error.response?.statusCode == 429 || // Rate limit
            (error.response?.statusCode ?? 0) >= 500; // Server errors
      default:
        return false;
    }
  }

  bool _canRetry(RequestOptions options) {
    // Seules les méthodes idempotentes peuvent être retry
    return [
      'GET',
      'HEAD',
      'PUT',
      'DELETE',
    ].contains(options.method.toUpperCase());
  }
}
