// lib/models/api_response.dart

// Import des modèles
import 'contact.dart';
import 'credential.dart';
import 'note.dart';
import 'task.dart';

/// Classe générique pour encapsuler les réponses de l'API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? code;
  final Map<String, dynamic>? errors;
  final PaginationMeta? pagination;
  final SearchMeta? searchMeta;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
    this.errors,
    this.pagination,
    this.searchMeta,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    PaginationMeta? pagination,
    SearchMeta? searchMeta,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      pagination: pagination,
      searchMeta: searchMeta,
    );
  }

  factory ApiResponse.error({
    String? message,
    String? code,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      code: code,
      errors: errors,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataConverter,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && dataConverter != null
          ? dataConverter(json['data'])
          : json['data'],
      message: json['message'],
      code: json['code'],
      errors: json['errors']?.cast<String, dynamic>(),
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'])
          : null,
      searchMeta: SearchMeta(
        search: json['search'],
        orderBy: json['orderBy'],
        orderDir: json['orderDir'],
      ),
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get hasPagination => pagination != null;
}

/// Métadonnées de pagination
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }

  PaginationMeta copyWith({
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNext,
    bool? hasPrev,
  }) {
    return PaginationMeta(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrev: hasPrev ?? this.hasPrev,
    );
  }
}

/// Métadonnées de recherche
class SearchMeta {
  final String? search;
  final String? orderBy;
  final String? orderDir;

  const SearchMeta({
    this.search,
    this.orderBy,
    this.orderDir,
  });

  factory SearchMeta.fromJson(Map<String, dynamic> json) {
    return SearchMeta(
      search: json['search'],
      orderBy: json['orderBy'],
      orderDir: json['orderDir'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'orderBy': orderBy,
      'orderDir': orderDir,
    };
  }

  SearchMeta copyWith({
    String? search,
    String? orderBy,
    String? orderDir,
  }) {
    return SearchMeta(
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      orderDir: orderDir ?? this.orderDir,
    );
  }
}

/// Liste paginée générique
class PaginatedList<T> {
  final List<T> items;
  final PaginationMeta pagination;
  final SearchMeta searchMeta;

  const PaginatedList({
    required this.items,
    required this.pagination,
    this.searchMeta = const SearchMeta(),
  });

  factory PaginatedList.fromApiResponse(
    ApiResponse<List<T>> response,
  ) {
    return PaginatedList(
      items: response.data ?? [],
      pagination: response.pagination ?? 
          const PaginationMeta(
            page: 1,
            limit: 10,
            total: 0,
            totalPages: 0,
            hasNext: false,
            hasPrev: false,
          ),
      searchMeta: response.searchMeta ?? const SearchMeta(),
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
  bool get hasMore => pagination.hasNext;
  bool get hasPrevious => pagination.hasPrev;

  PaginatedList<T> copyWith({
    List<T>? items,
    PaginationMeta? pagination,
    SearchMeta? searchMeta,
  }) {
    return PaginatedList(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      searchMeta: searchMeta ?? this.searchMeta,
    );
  }

  /// Ajoute des éléments à la fin de la liste (pour le chargement infini)
  PaginatedList<T> appendItems(PaginatedList<T> newPage) {
    return PaginatedList(
      items: [...items, ...newPage.items],
      pagination: newPage.pagination,
      searchMeta: newPage.searchMeta,
    );
  }

  /// Remplace complètement la liste (pour la recherche/filtre)
  PaginatedList<T> replaceItems(PaginatedList<T> newList) {
    return PaginatedList(
      items: newList.items,
      pagination: newList.pagination,
      searchMeta: newList.searchMeta,
    );
  }
}

/// État de chargement pour les listes paginées
enum LoadingState {
  initial,
  loading,
  loadingMore,
  loaded,
  error,
  refreshing,
}

/// Wrapper pour l'état d'une liste paginée avec gestion du chargement
class PaginatedListState<T> {
  final PaginatedList<T> list;
  final LoadingState state;
  final String? error;

  const PaginatedListState({
    required this.list,
    required this.state,
    this.error,
  });

  factory PaginatedListState.initial() {
    return PaginatedListState(
      list: PaginatedList(
        items: [],
        pagination: const PaginationMeta(
          page: 1,
          limit: 10,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        ),
      ),
      state: LoadingState.initial,
    );
  }

  bool get isInitial => state == LoadingState.initial;
  bool get isLoading => state == LoadingState.loading;
  bool get isLoadingMore => state == LoadingState.loadingMore;
  bool get isLoaded => state == LoadingState.loaded;
  bool get isError => state == LoadingState.error;
  bool get isRefreshing => state == LoadingState.refreshing;
  bool get hasError => error != null;
  bool get isEmpty => list.isEmpty && isLoaded;
  bool get canLoadMore => list.hasMore && !isLoadingMore && !isError;

  PaginatedListState<T> copyWith({
    PaginatedList<T>? list,
    LoadingState? state,
    String? error,
  }) {
    return PaginatedListState(
      list: list ?? this.list,
      state: state ?? this.state,
      error: error,
    );
  }

  PaginatedListState<T> toLoading() {
    return copyWith(
      state: LoadingState.loading,
      error: null,
    );
  }

  PaginatedListState<T> toLoadingMore() {
    return copyWith(
      state: LoadingState.loadingMore,
      error: null,
    );
  }

  PaginatedListState<T> toRefreshing() {
    return copyWith(
      state: LoadingState.refreshing,
      error: null,
    );
  }

  PaginatedListState<T> toLoaded(PaginatedList<T> newList) {
    return copyWith(
      list: newList,
      state: LoadingState.loaded,
      error: null,
    );
  }

  PaginatedListState<T> toError(String errorMessage) {
    return copyWith(
      state: LoadingState.error,
      error: errorMessage,
    );
  }

  PaginatedListState<T> appendPage(PaginatedList<T> newPage) {
    return copyWith(
      list: list.appendItems(newPage),
      state: LoadingState.loaded,
      error: null,
    );
  }
}

/// Types spécifiques pour chaque entité
typedef ContactsResponse = ApiResponse<List<Contact>>;
typedef ContactResponse = ApiResponse<Contact>;
typedef ContactsPaginatedList = PaginatedList<Contact>;
typedef ContactsListState = PaginatedListState<Contact>;

typedef CredentialsResponse = ApiResponse<List<Credential>>;
typedef CredentialResponse = ApiResponse<Credential>;
typedef CredentialsPaginatedList = PaginatedList<Credential>;
typedef CredentialsListState = PaginatedListState<Credential>;

typedef NotesResponse = ApiResponse<List<Note>>;
typedef NoteResponse = ApiResponse<Note>;
typedef NotesPaginatedList = PaginatedList<Note>;
typedef NotesListState = PaginatedListState<Note>;

typedef TasksResponse = ApiResponse<List<Task>>;
typedef TaskResponse = ApiResponse<Task>;
typedef TasksPaginatedList = PaginatedList<Task>;
typedef TasksListState = PaginatedListState<Task>;

