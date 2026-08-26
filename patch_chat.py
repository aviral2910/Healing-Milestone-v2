import re

with open('../healing_milestones_backend/app/api/endpoints/chat.py', 'r') as f:
    content = f.read()

if 'import uuid' not in content:
    content = 'import uuid\n' + content

old_code = '''    if str(current_user.id) == target_user_id:
        raise HTTPException(status_code=400, detail="Cannot chat with yourself")

    target_user = db.query(User).filter(User.id == target_user_id).first()
    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")
        
    db_firestore = get_firestore_client()
    if not db_firestore:
        raise HTTPException(status_code=500, detail="Chat server misconfigured")

    # Check for mutual follow using the relationship backrefs
    is_following_target = any(str(u.id) == target_user_id for u in current_user.following)'''

new_code = '''    if str(current_user.id) == target_user_id or current_user.firebase_uid == target_user_id:
        raise HTTPException(status_code=400, detail="Cannot chat with yourself")

    try:
        uuid.UUID(target_user_id)
        target_user = db.query(User).filter(User.id == target_user_id).first()
    except ValueError:
        target_user = db.query(User).filter(User.firebase_uid == target_user_id).first()

    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")
        
    db_firestore = get_firestore_client()
    if not db_firestore:
        raise HTTPException(status_code=500, detail="Chat server misconfigured")

    # Check for mutual follow using the relationship backrefs
    is_following_target = any(str(u.id) == str(target_user.id) for u in current_user.following)'''

content = content.replace(old_code, new_code)

with open('../healing_milestones_backend/app/api/endpoints/chat.py', 'w') as f:
    f.write(content)
