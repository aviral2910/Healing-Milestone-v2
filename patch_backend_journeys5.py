import re

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'r') as f:
    content = f.read()

old_code = '"description": journey.description,'
new_code = '"description": getattr(journey, "description", None),'

content = content.replace(old_code, new_code)

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'w') as f:
    f.write(content)
