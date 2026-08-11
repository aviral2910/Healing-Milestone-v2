import 'dart:convert';

void main() {
  final jsonString = '''
  {
    "taggedUsers": [
      {
        "id": "1",
        "displayName": "Test"
      }
    ]
  }
  ''';
  
  final json = jsonDecode(jsonString);
  try {
    final list = (json['taggedUsers'] ?? json['tagged_users'] as List?)
        ?.map((x) => x as Map<String, dynamic>)
        .toList() ?? [];
    print('Success: $list');
  } catch (e, stack) {
    print('Error: $e\n$stack');
  }
}
