import re
with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

content = re.sub(
    r'final validRooms = rooms[\s]*\.where\([\s]*\(r\) =>[\s]*r\.participants\.contains\(currentUser\.userId\) &&[\s]*r\.participants\.length > 1,[\s]*\)',
    'final validRooms = rooms.where((r) => r.participants.contains(currentUser.userId) && r.participants.length > 1 && r.type != "support")',
    content
)

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
