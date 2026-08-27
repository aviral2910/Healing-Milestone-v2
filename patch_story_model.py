import re

with open('lib/core/models/story_model.dart', 'r') as f:
    content = f.read()

old_published = "publishedAt: (map['publishedAt'] ?? map['published_at'] as Timestamp?)?.toDate() ?? DateTime.now(),"
new_published = "publishedAt: (map['publishedAt'] ?? map['published_at']) is Timestamp ? ((map['publishedAt'] ?? map['published_at']) as Timestamp).toDate() : ((map['publishedAt'] ?? map['published_at']) is String ? (DateTime.tryParse(map['publishedAt'] ?? map['published_at']) ?? DateTime.now()) : DateTime.now()),"
content = content.replace(old_published, new_published)

old_verified = "verifiedAt: (map['verifiedAt'] ?? map['verified_at'] as Timestamp?)?.toDate(),"
new_verified = "verifiedAt: (map['verifiedAt'] ?? map['verified_at']) is Timestamp ? ((map['verifiedAt'] ?? map['verified_at']) as Timestamp).toDate() : ((map['verifiedAt'] ?? map['verified_at']) is String ? DateTime.tryParse(map['verifiedAt'] ?? map['verified_at']) : null),"
content = content.replace(old_verified, new_verified)

with open('lib/core/models/story_model.dart', 'w') as f:
    f.write(content)
