with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "r") as f:
    content = f.read()

# Fix the first crash: .first.authorRole
# Replace:
# role: milestonesAsync
#                                           .value
#                                           ?.items
#                                           .first
#                                           .authorRole,

import re
content = re.sub(
    r"role: milestonesAsync[\s]*\.value[\s]*\?\.items[\s]*\.first[\s]*\.authorRole,",
    "role: (milestonesAsync.value?.items.isNotEmpty == true ? milestonesAsync.value!.items.first.authorRole : null),",
    content
)

content = re.sub(
    r"title: milestonesAsync[\s]*\.value[\s]*\?\.items[\s]*\.first[\s]*\.authorTitle,",
    "title: (milestonesAsync.value?.items.isNotEmpty == true ? milestonesAsync.value!.items.first.authorTitle : null),",
    content
)

with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "w") as f:
    f.write(content)

