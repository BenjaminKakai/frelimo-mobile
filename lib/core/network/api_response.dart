/// The backend wraps every response in `{ success, data, timestamp }`.
/// `ApiResponse<T>` is a tiny envelope parser so screens can pull `.data`
/// safely. For paginated lists the backend nests `{ items, total, page, ... }`
/// inside `data` — `PaginatedData<T>` handles that.
class PaginatedData<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedData({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return PaginatedData<T>(
      items: raw.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? timestamp;
  final String? message;

  ApiResponse({required this.success, this.data, this.timestamp, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'] as T?,
      timestamp: json['timestamp']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
