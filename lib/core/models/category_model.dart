class CategoryListModel {
  final String categoryId;
  final String categoryName;
  final int storyCount;
  final List<String> storiesList;

  CategoryListModel({
    required this.categoryId,
    required this.categoryName,
    this.storyCount = 0,
    this.storiesList = const [],
  });

  CategoryListModel copyWith({
    String? categoryId,
    String? categoryName,
    int? storyCount,
    List<String>? storiesList,
  }) {
    return CategoryListModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      storyCount: storyCount ?? this.storyCount,
      storiesList: storiesList ?? this.storiesList,
    );
  }
}
