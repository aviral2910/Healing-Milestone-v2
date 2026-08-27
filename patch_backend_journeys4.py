import re

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'r') as f:
    content = f.read()

old_code = '"author_avatar": journey.user.avatar_url if journey.user else None,'
new_code = '"author_avatar": journey.user.profile_picture if journey.user else None,'

content = content.replace(old_code, new_code)

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'w') as f:
    f.write(content)
