import re

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'r') as f:
    content = f.read()

old_code = """            "user_id": str(journey.user_id),
            "author_name": journey.author.full_name if journey.author else None,
            "author_avatar": journey.author.avatar_url if journey.author else None,"""

new_code = """            "user_id": str(journey.user_id),
            "author_name": journey.user.full_name if journey.user else None,
            "author_avatar": journey.user.avatar_url if journey.user else None,"""

content = content.replace(old_code, new_code)

# We should also ensure journey.user is joinedloaded to prevent N+1 queries.
old_query = "journeys = db.query(Journey).options(selectinload(Journey.categories)).filter(Journey.id.in_(valid_ids)).all()"
new_query = "journeys = db.query(Journey).options(selectinload(Journey.categories), joinedload(Journey.user)).filter(Journey.id.in_(valid_ids)).all()"
content = content.replace(old_query, new_query)

# Add joinedload import if not present
if "joinedload" not in content:
    content = content.replace("from sqlalchemy.orm import Session, selectinload", "from sqlalchemy.orm import Session, selectinload, joinedload")
    content = content.replace("from sqlalchemy.orm import selectinload", "from sqlalchemy.orm import selectinload, joinedload")

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'w') as f:
    f.write(content)
