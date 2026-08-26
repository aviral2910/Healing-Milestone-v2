with open('firestore.rules', 'r') as f:
    content = f.read()

old_rule = "allow read: if request.auth != null && (request.auth.uid in resource.data.participants || isAdmin());"
new_rule = "allow read: if request.auth != null && (resource == null || request.auth.uid in resource.data.participants || isAdmin());"

content = content.replace(old_rule, new_rule)

with open('firestore.rules', 'w') as f:
    f.write(content)
