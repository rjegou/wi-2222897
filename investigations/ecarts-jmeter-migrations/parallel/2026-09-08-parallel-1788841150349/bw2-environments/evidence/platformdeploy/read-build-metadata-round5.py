import json
from pathlib import Path

import requests


TOKEN_PATH = Path(r"C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt")
BASE = "https://dev.azure.com/cegid/Retail/_apis/build/builds"


def main():
    token = TOKEN_PATH.read_text(encoding="utf-8").strip()
    session = requests.Session()
    session.auth = ("", token)
    session.headers.update({"Accept": "application/json"})
    for build_id in (4432602, 4432554, 4432510):
        for suffix in (f"/{build_id}", f"/{build_id}/artifacts"):
            response = session.get(BASE + suffix, params={"api-version": "7.1"}, timeout=30)
            response.raise_for_status()
            payload = response.json()
            if suffix.endswith("/artifacts"):
                print(json.dumps({
                    "kind": "artifacts",
                    "id": build_id,
                    "count": payload.get("count"),
                    "names": [item.get("name") for item in payload.get("value", [])],
                }, sort_keys=True))
            else:
                print(json.dumps({
                    "kind": "build",
                    "id": payload.get("id"),
                    "number": payload.get("buildNumber"),
                    "status": payload.get("status"),
                    "result": payload.get("result"),
                    "branch": payload.get("sourceBranch"),
                    "sourceVersion": payload.get("sourceVersion"),
                    "definitionId": (payload.get("definition") or {}).get("id"),
                    "definitionName": (payload.get("definition") or {}).get("name"),
                    "repository": (payload.get("repository") or {}).get("name"),
                }, sort_keys=True))


if __name__ == "__main__":
    main()
