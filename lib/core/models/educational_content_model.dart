enum EducationalContentType {
  story,
  video,
  pdf,
  webinar,
  workshop,
  conference,
  podcast
}

class EducationalContentModel {
  final String contentId;
  final String title;
  final String description;
  final EducationalContentType type;
  final String url;
  final String doctorId;
  final String doctorName;
  final String? thumbnailUrl;
  final DateTime publishedAt;

  EducationalContentModel({
    required this.contentId,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.doctorId,
    required this.doctorName,
    this.thumbnailUrl,
    required this.publishedAt,
  });

  EducationalContentModel copyWith({
    String? contentId,
    String? title,
    String? description,
    EducationalContentType? type,
    String? url,
    String? doctorId,
    String? doctorName,
    String? thumbnailUrl,
    DateTime? publishedAt,
  }) {
    return EducationalContentModel(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      url: url ?? this.url,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
