import requests

def get_main_domains(email, api_key):
    headers = {
        "X-Auth-Email": email,
        "X-Auth-Key": api_key,
        "Content-Type": "application/json"
    }
    url = "https://api.cloudflare.com/client/v4/zones"
    resp = requests.get(url, headers=headers)
    if resp.status_code != 200:
        return []
    data = resp.json()["result"]
    return [d["name"] for d in data]