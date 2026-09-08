import os, base64, json, requests
from urllib.parse import quote

out = os.environ["W12_OUT"]
h = {"Authorization": "Basic " + base64.b64encode((":" + os.environ["W12_PAT"]).encode()).decode()}
base = "https://dev.azure.com/cegid/Retail/_apis"
s = requests.Session(); s.verify = True
repos = s.get(base + "/git/repositories", headers=h, params={"api-version":"7.1"}, timeout=60).json().get("value", [])
found = []
for repo in repos:
    refs = s.get(base + "/git/repositories/" + repo["id"] + "/refs", headers=h, params={"filter":"refs/heads/codex", "api-version":"7.1"}, timeout=60).json().get("value", [])
    for ref in refs:
        found.append({"repo":repo["name"], "repoId":repo["id"], "name":ref["name"], "objectId":ref["objectId"]})
        prs = s.get(base + "/git/repositories/" + repo["id"] + "/pullrequests", headers=h, params={"searchCriteria.sourceRefName":ref["name"], "api-version":"7.1"}, timeout=60).json().get("value", [])
        found[-1]["pullRequests"] = [{"id":p["pullRequestId"],"status":p["status"],"title":p.get("title","")[:160],"source":p.get("sourceRefName"),"target":p.get("targetRefName")} for p in prs]
json.dump(found, open(os.path.join(out,"codex-ref-audit.json"), "w", encoding="utf-8"), indent=2)
print(json.dumps(found, indent=2))
