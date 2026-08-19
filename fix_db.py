import re

with open('../healing_milestones_backend/app/models/journey.py', 'r') as f:
    content = f.read()

content = content.replace(
    "media_url = Column(String, nullable=True)",
    "media_url = Column(String, nullable=True)\n    audio_url = Column(String, nullable=True)"
)

# Wait, does media_url exist? Let's check JourneyMilestone again
