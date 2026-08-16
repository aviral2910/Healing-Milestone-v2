class OffsetPaginatedState<T> {
  final List<T> items;
  final bool isEnd;
  final int skip;

  OffsetPaginatedState({
    required this.items,
    this.isEnd = false,
    this.skip = 0,
  });

  OffsetPaginatedState<T> copyWith({
    List<T>? items,
    bool? isEnd,
    int? skip,
  }) {
    return OffsetPaginatedState<T>(
      items: items ?? this.items,
      isEnd: isEnd ?? this.isEnd,
      skip: skip ?? this.skip,
    );
  }
}
