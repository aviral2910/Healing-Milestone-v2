import re

path = 'lib/features/posts/data/ai_story_service.dart'
with open(path, 'r') as f:
    content = f.read()

content = content.replace("import 'package:firebase_vertexai/firebase_vertexai.dart';", "import 'package:firebase_ai/firebase_ai.dart';")
content = content.replace("FirebaseVertexAI.instance", "FirebaseAI.instance")
content = content.replace("DEBUG: Current Firebase User ID", "DEBUG User ID")

with open(path, 'w') as f:
    f.write(content)
