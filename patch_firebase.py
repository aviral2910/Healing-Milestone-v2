import json

with open('firebase.json', 'r') as f:
    data = json.load(f)

if 'firestore' not in data:
    data['firestore'] = {}

data['firestore']['indexes'] = 'firestore.indexes.json'

with open('firebase.json', 'w') as f:
    json.dump(data, f, indent=2)
