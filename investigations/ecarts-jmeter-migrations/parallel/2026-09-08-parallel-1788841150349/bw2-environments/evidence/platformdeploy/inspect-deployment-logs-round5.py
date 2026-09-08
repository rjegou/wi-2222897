import io
import json
import re
import zipfile
from pathlib import Path

import requests


TOKEN_PATH = Path(r"C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt")
BASE = "https://dev.azure.com/cegid/Retail/_apis/build/builds"
TARGETS = {
    4432602: ("v22-Fix_Deployment_logs", "v23-Fix_Deployment_logs"),
    4432554: ("v26-Fix_Deployment_logs",),
    4432510: ("v26-Fix_Deployment_logs",),
}
PATTERNS = re.compile(r"PlatformDeploy|foundPlatformDeployVersion|checkout|refs/tags|commit|5\.0\.|6\.0\.|7-Zip|Search Artefact", re.I)
URL_PATTERN = re.compile(r"https?://\S+")


def scrub(line):
    return URL_PATTERN.sub("<url-redacted>", line).strip()


def main():
    token = TOKEN_PATH.read_text(encoding="utf-8").strip()
    session = requests.Session()
    session.auth = ("", token)
    session.headers.update({"Accept": "application/json"})
    for build_id, prefixes in TARGETS.items():
        artifact_payload = session.get(f"{BASE}/{build_id}/artifacts", params={"api-version": "7.1"}, timeout=30).json()
        for artifact in artifact_payload.get("value", []):
            name = artifact.get("name", "")
            if not any(name.startswith(prefix) for prefix in prefixes):
                continue
            download_url = (artifact.get("resource") or {}).get("downloadUrl")
            if not download_url:
                print(json.dumps({"build": build_id, "artifact": name, "error": "downloadUrl absent"}, sort_keys=True))
                continue
            response = session.get(download_url, timeout=60)
            response.raise_for_status()
            matches = []
            members = []
            with zipfile.ZipFile(io.BytesIO(response.content)) as archive:
                for member in archive.infolist():
                    members.append(member.filename)
                    if member.is_dir() or member.file_size > 10_000_000:
                        continue
                    raw = archive.read(member)
                    texts = [raw.decode("utf-8", errors="replace")]
                    if b"\x00" in raw:
                        texts.append(raw.decode("utf-16", errors="replace"))
                    for text in texts:
                        for line in text.splitlines():
                            if PATTERNS.search(line):
                                matches.append({"file": member.filename, "line": scrub(line)[:500]})
            print(json.dumps({"build": build_id, "artifact": name, "archiveBytes": len(response.content), "members": members[:100], "matches": matches[:200]}, sort_keys=True))


if __name__ == "__main__":
    main()
