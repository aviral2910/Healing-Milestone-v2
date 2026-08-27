import re

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'r') as f:
    content = f.read()

old_batch = """@router.post("/batch", response_model=List[JourneyResponse])
def get_journeys_batch(
    request: BatchRequest,
    db: Session = Depends(get_db)
):
    journeys = db.query(Journey).options(selectinload(Journey.categories)).filter(Journey.id.in_(request.ids)).all()
    
    response_list = []"""

new_batch = """@router.post("/batch", response_model=List[JourneyResponse])
def get_journeys_batch(
    request: BatchRequest,
    db: Session = Depends(get_db)
):
    import uuid
    valid_ids = []
    for str_id in request.ids:
        try:
            valid_ids.append(uuid.UUID(str_id))
        except ValueError:
            pass

    if not valid_ids:
        return []

    journeys = db.query(Journey).options(selectinload(Journey.categories)).filter(Journey.id.in_(valid_ids)).all()
    
    response_list = []"""
content = content.replace(old_batch, new_batch)

with open('/Users/aviraldixit/self/healing_milestones_backend/app/api/endpoints/journeys.py', 'w') as f:
    f.write(content)
