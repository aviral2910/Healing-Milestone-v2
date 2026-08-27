import requests

try:
    res = requests.post("http://localhost:8000/api/journeys/batch", json={"ids": ["test"]})
    print("Journeys batch response:", res.status_code, res.text)
except Exception as e:
    print("Journeys batch failed:", e)

try:
    res = requests.post("http://localhost:8000/api/stories/batch", json={"ids": ["test"]})
    print("Stories batch response:", res.status_code, res.text)
except Exception as e:
    print("Stories batch failed:", e)
