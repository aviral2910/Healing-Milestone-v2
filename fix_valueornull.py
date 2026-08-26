import re

with open("lib/features/search/data/search_providers.dart", "r") as f:
    content = f.read()

content = content.replace("state.valueOrNull", "state.asData?.value")

with open("lib/features/search/data/search_providers.dart", "w") as f:
    f.write(content)
