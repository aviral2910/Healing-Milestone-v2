import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("pendingRequestsAsync.valueOrNull?.length ?? 0", "pendingRequestsAsync.value?.length ?? 0")

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
