import requests

def fetch_data(url):
    response = requests.get(url)
    return response.json()

url = "https://getfullyear.com/api/year"
data = fetch_data(url)

print(data["sponsored_by"],data["year"])
