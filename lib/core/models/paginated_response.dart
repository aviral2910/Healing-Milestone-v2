class PaginatedResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final bool isEnd;

  PaginatedResponse({
    required this.items,
    this.nextCursor,
    this.isEnd = false,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List)
          .map((i) => fromJsonT(i as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor']?.toString() ?? json['next_cursor']?.toString(),
      isEnd: json['isEnd'] as bool? ?? json['is_end'] as bool? ?? false,
    );
  }
}
