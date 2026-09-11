#!/usr/bin/env python3
"""Read-only Azure DevOps coverage collector for WI-2222897."""
import argparse, base64, hashlib, json, os, re, subprocess, sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlencode
import requests

ORG = "https://dev.azure.com/cegid"
PROJECT = "Retail"
API = "7.1"
ALLOWED_BUILDS = {4447425, 4440884, 4445575, 4432554}

def my_documents():
    try:
        r = subprocess.run(["powershell", "-NoProfile", "-Command", "[Environment]::GetFolderPath('MyDocuments')"], capture_output=True, text=True, check=True)
        return r.stdout.strip()
    except Exception:
        return str(Path.home() / "Documents")

def find_pat():
    canonical = str(Path(my_documents()) / "azureToken.txt")
    candidates = [canonical, r"C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt"]
    for p in candidates:
        if os.path.isfile(p):
            value = Path(p).read_text(encoding="utf-8").strip()
            if value:
                return p, value
    return None, None

def digest(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()

class Client:
    def __init__(self, pat):
        raw = (":" + pat).encode("ascii")
        self.headers = {"Authorization": "Basic " + base64.b64encode(raw).decode("ascii"), "X-TFS-FedAuthRedirect": "Suppress", "Accept": "application/json"}
        self.s = requests.Session()
        self.s.headers.update(self.headers)
        self.events = []

    def get(self, path, params=None, binary=False):
        url = ORG + "/" + PROJECT + path
        extra = {"Accept": "application/octet-stream"} if binary else None
        r = self.s.get(url, params=params, headers=extra, timeout=90, verify=True, allow_redirects=False)
        event = {"path": path, "status": r.status_code, "contentLength": len(r.content)}
        self.events.append(event)
        r.raise_for_status()
        return r.content if binary else r.json(), r.headers

    def pages(self, path, params=None):
        params = dict(params or {})
        params.setdefault("api-version", API)
        params.setdefault("$top", 1000)
        values, pages = [], []
        seen_page_ids = set()
        token = None
        skip = int(params.get("$skip", 0) or 0)
        while True:
            q = dict(params)
            if token:
                q["continuationToken"] = token
            elif skip:
                q["$skip"] = skip
            body, headers = self.get(path, q)
            page = body.get("value", body if isinstance(body, list) else [])
            page_ids = [x.get("id") for x in page if isinstance(x, dict) and x.get("id") is not None]
            repeated = bool(page_ids) and hashlib.sha256(json.dumps(page_ids, sort_keys=True).encode()).hexdigest() in seen_page_ids
            fingerprint = hashlib.sha256(json.dumps(page_ids, sort_keys=True).encode()).hexdigest() if page_ids else None
            if fingerprint: seen_page_ids.add(fingerprint)
            values.extend(page)
            next_token = headers.get("x-ms-continuationtoken") or headers.get("X-MS-ContinuationToken") or body.get("continuationToken")
            pages.append({"status": 200, "skip": skip, "count": len(page), "ids": page_ids, "repeatedPage": repeated, "continuationPresent": bool(next_token), "continuationSha256": digest(next_token) if next_token else None})
            if repeated:
                pages[-1]["complete"] = False; pages[-1]["termination"] = "repeated-page"; return values, pages
            if next_token:
                token = next_token
                continue
            top = int(params.get("$top", 1000) or 1000)
            if len(page) < top:
                pages[-1]["complete"] = True
                return values, pages
            # Test results commonly paginate with $skip and no continuation header.
            skip += len(page)

def identity(result):
    title = result.get("testCaseTitle") or result.get("testCase", {}).get("name") or result.get("automatedTestName") or ""
    return {
        "plugin": "InventoryTracking" if title.startswith(tuple(str(i).zfill(3) for i in range(1, 100))) else None,
        "variant": "Cur" if "-Cur" in title or " Cur" in title else ("Fix" if "-Fix" in title or " Fix" in title else None),
        "plan": title.split(" - TC ", 1)[0],
        "case": ("TC " + title.rsplit(" - TC ", 1)[1]) if " - TC " in title else title,
        "testCaseReferenceId": result.get("testCaseReferenceId"),
        "resultId": result.get("id"),
        "attempt": result.get("attempt") or result.get("revision") or 1,
        "testRunId": result.get("testRun", {}).get("id") or result.get("testRunId"),
        "outcome": result.get("outcome"),
        "comment": result.get("errorMessage") or result.get("comment") or "",
    }

def analyze(run, results, pages, attachments, attachment_pages):
    ids = [identity(x) for x in results]
    run_variant = "Cur" if "Cur" in (run.get("name") or "") else ("Fix" if "Fix" in (run.get("name") or "") else None)
    for x in ids:
        if not x.get("variant"):
            x["variant"] = run_variant
    logical = {}
    for x in ids:
        key = "|".join([str(x.get("plan")), str(x.get("case")), str(x.get("testCaseReferenceId"))])
        logical.setdefault(key, []).append(x)
    duplicates = [{"key": k, "count": len(v), "attempts": [x.get("attempt") for x in v]} for k, v in logical.items() if len(v) > 1]
    retry_groups = [x for x in duplicates if len(set(x["attempts"])) > 1]
    result_ids = [x.get("resultId") for x in ids if x.get("resultId") is not None]
    unique_ids = len(result_ids) == len(set(result_ids))
    expected = run.get("totalTests")
    try:
        count_matches = expected is not None and int(expected) == len(result_ids)
    except (TypeError, ValueError):
        count_matches = False
    return {
        "runId": run.get("id"), "name": run.get("name"), "state": run.get("state"), "total": len(ids),
        "passed": sum(x.get("outcome") == "Passed" for x in ids),
        "failed": sum(x.get("outcome") == "Failed" for x in ids),
        "skipped": sum(x.get("outcome") in ("Skipped", "NotExecuted", "Unanalyzed") for x in ids),
        "pages": pages, "resultIdsUnique": unique_ids, "totalTests": expected, "totalTestsMatches": count_matches, "resultsComplete": bool(pages) and pages[-1].get("complete", False) and unique_ids and count_matches, "attachmentCount": len(attachments), "attachmentPages": attachment_pages,
        "identities": ids, "publishedPlans": sorted({x.get("plan") for x in ids if x.get("plan")}), "duplicateKeys": duplicates, "retryGroups": retry_groups,
    }

def compare(left, right):
    def keyed(run):
        return {"|".join([str(x.get("plan")), str(x.get("case")), str(x.get("testCaseReferenceId"))]): x for x in run["identities"]}
    a, b = keyed(left), keyed(right)
    common = set(a) & set(b)
    return {"left": left["runId"], "right": right["runId"], "leftOnly": sorted(set(a)-set(b)), "rightOnly": sorted(set(b)-set(a)), "statusChanges": [{"key": k, "left": a[k].get("outcome"), "right": b[k].get("outcome"), "leftComment": a[k].get("comment"), "rightComment": b[k].get("comment")} for k in sorted(common) if a[k].get("outcome") != b[k].get("outcome") or a[k].get("comment") != b[k].get("comment")]}

def timeline_signals(records):
    stages, tasks = [], []
    for x in records:
        item = {"name": x.get("name"), "type": x.get("type"), "state": x.get("state"), "result": x.get("result"), "recordId": x.get("id"), "logId": (x.get("log") or {}).get("id")}
        if str(x.get("type", "")).lower() == "stage": stages.append(item)
        if str(x.get("type", "")).lower() == "task": tasks.append(item)
    jmeter = [x for x in stages + tasks if re.search(r"jmeter|test plan|load test", str(x.get("name")), re.I)]
    run_tasks = [x for x in tasks if re.search(r"Run Jmeter Tests Campaign", str(x.get("name")), re.I)]
    runner = [x for x in run_tasks if x.get("state") == "completed" and x.get("result") in ("succeeded", "succeededWithIssues", "failed")]
    skipped = [x for x in run_tasks if x.get("state") == "skipped" or x.get("result") == "skipped"]
    return {"stages": stages, "tasks": tasks, "jmeterRecords": jmeter, "runJmeterTasks": run_tasks, "runnerExecuted": bool(runner), "jmeterSkipped": bool(skipped), "runnerRecords": runner, "skippedRecords": skipped, "variantRunnerEvidence": {"Cur": [x for x in run_tasks if "cur" in str(x.get("name")).lower()], "Fix": [x for x in run_tasks if "fix" in str(x.get("name")).lower()]}}

def discover_runs(client, build_uri):
    params = {"buildUri": build_uri, "api-version": API, "$top": 1000}
    runs, pages = client.pages("/_apis/test/runs", params)
    return runs, {"endpoint": "/_apis/test/runs", "params": params, "pages": pages, "responseCount": len(runs), "responseRecords": [{"id": x.get("id"), "name": x.get("name"), "state": x.get("state"), "totalTests": x.get("totalTests"), "build": x.get("build"), "buildUri": x.get("buildUri")} for x in runs]}

def run_matches_build(run, build_id):
    build = run.get("build") if isinstance(run.get("build"), dict) else {}
    canonical = f"vstfs:///Build/Build/{build_id}"
    try:
        if build.get("id") is not None and int(build["id"]) != build_id: return False
    except (TypeError, ValueError):
        return False
    for explicit in (build.get("uri"), run.get("buildUri")):
        if explicit is not None and str(explicit).rstrip("/").lower() != canonical.lower(): return False
    return True

def discovery_verdict(provenance, accepted_count):
    if provenance is None: return "discovery-failed"
    if not provenance.get("pages") or not provenance["pages"][-1].get("complete", False): return "discovery-incomplete"
    if accepted_count == 0 and provenance.get("responseCount", 0) == 0: return "complete-empty"
    if accepted_count == 0: return "all-runs-rejected"
    return "attribution-valid"

def variant_counts(runs):
    if not runs or any(not x.get("resultsComplete") for x in runs): return {"Cur": None, "Fix": None}
    counts = {}
    for variant in ("Cur", "Fix"):
        selected = [x for x in runs if variant == ("Cur" if "Cur" in (x.get("name") or "") else "Fix" if "Fix" in (x.get("name") or "") else None)]
        counts[variant] = sum(x["total"] for x in selected) if selected else None
    return counts

def log_signals(client, build_id):
    logs, _ = client.pages(f"/_apis/build/builds/{build_id}/logs", {"api-version": API, "$top": 1000})
    announced, loaded, errors, cleanup, read_errors = set(), set(), [], [], []
    for log in logs:
        lid = log.get("id")
        if not lid: continue
        try:
            raw, _ = client.get(f"/_apis/build/builds/{build_id}/logs/{lid}", {"api-version": API}, binary=True)
            try:
                obj = json.loads(raw.decode("utf-8", "replace"))
                text = "\n".join(str(x) for x in obj.get("value", [])) if isinstance(obj, dict) else raw.decode("utf-8", "replace")
            except json.JSONDecodeError:
                text = raw.decode("utf-8", "replace")
            announced.update(re.findall(r"Launch test Plan ['\"]([^'\"]+)", text, re.I))
            loaded.update(re.findall(r"(?:Starting|Running|Loaded)\s+(?:test plan\s+)?['\"]?([0-9]{3}-[^'\"\r\n]+)", text, re.I))
            for line_no, line in enumerate(text.splitlines(), 1):
                if "NonGUIDriver" in line or "Problem loading XML" in line or "HeaderManager" in line:
                    errors.append(line[:500])
                if re.search(r"cleanup|clean-up|remove-container|docker\s+(rm|stop)|Remove-Item", line, re.I):
                    low = line.lower()
                    outcome = "UNKNOWN"
                    if re.search(r"(removed|deleted|success|succeeded|exited|not found)", low): outcome = "reported-success-or-benign"
                    if re.search(r"(failed|error|denied|cannot|exception)", low): outcome = "reported-failure"
                    cleanup.append({"logId": lid, "line": line_no, "operation": line[:500], "resultObserved": outcome, "scope": "UNKNOWN"})
        except requests.RequestException as exc:
            read_errors.append({"logId": lid, "status": getattr(exc.response, "status_code", None), "error": str(exc)[:300]})
    return {"logCount": len(logs), "announcedPlans": sorted(announced), "loadedPlans": sorted(loaded), "nonGuidriverErrors": errors, "cleanupSignals": cleanup, "logReadErrors": read_errors}

def jmx_evidence(client, build):
    repo = build.get("repository") or {}
    source = build.get("sourceVersion")
    if not repo.get("id") or not source:
        return {"status": "UNKNOWN", "reason": "repository or sourceVersion absent"}
    try:
        params = {
            "scopePath": "/", "recursionLevel": "Full", "versionDescriptor.version": source,
            "versionDescriptor.versionType": "commit", "includeContent": "false", "api-version": API, "$top": 1000
        }
        listing, _ = client.get(f"/_apis/git/repositories/{repo['id']}/items", params
        )
        entries = listing.get("value", []) if isinstance(listing, dict) else []
        jmx_entries = [x for x in entries if str(x.get("path", "")).lower().endswith(".jmx")]
        hashes, missing_object_ids = [], []
        for entry in jmx_entries:
            path = entry.get("path")
            meta, _ = client.get(f"/_apis/git/repositories/{repo['id']}/items", {
                "path": path, "versionDescriptor.version": source,
                "versionDescriptor.versionType": "commit", "includeContent": "false", "api-version": API
            })
            blob_id = meta.get("objectId")
            if not blob_id:
                missing_object_ids.append(path); continue
            raw, _ = client.get(f"/_apis/git/repositories/{repo['id']}/blobs/{blob_id}", {"download": "true", "api-version": API}, binary=True)
            hashes.append({"path": path, "objectId": blob_id, "size": len(raw), "sha256": hashlib.sha256(raw).hexdigest().upper()})
        return {"status": "FACT" if hashes else "UNKNOWN", "sourceVersion": source, "repositoryId": repo.get("id"), "query": params, "jmxCount": len(hashes), "inventoryExhaustive": "UNKNOWN", "missingObjectIds": missing_object_ids, "items": hashes,
                "runtimeConsumption": "UNKNOWN"}
    except requests.RequestException as exc:
        return {"status": "UNKNOWN", "sourceVersion": source,
                "reason": "git item unavailable", "httpStatus": getattr(exc.response, "status_code", None)}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", required=True)
    ap.add_argument("--build", nargs="+", type=int, default=sorted(ALLOWED_BUILDS))
    args = ap.parse_args()
    invalid = set(args.build) - ALLOWED_BUILDS
    if invalid:
        ap.error("build outside strict whitelist: " + ",".join(map(str, sorted(invalid))))
    out = Path(args.output)
    if out.exists() and any(out.iterdir()):
        ap.error("output directory is non-empty; choose a new collection folder")
    out.mkdir(parents=True, exist_ok=True)
    collected = {"collectedAtUtc": datetime.now(timezone.utc).isoformat(), "collectorVersion": "attestation-round3", "organization": ORG, "project": PROJECT, "buildIds": args.build, "runIds": [], "tlsVerify": True, "patPath": None, "http": [], "builds": [], "runDiscovery": [], "testRuns": [], "comparisons": [], "verdicts": [], "errors": []}
    path, pat = find_pat()
    collected["patPath"] = path
    if not pat:
        collected["errors"].append({"classification": "local-secret-path-missing", "resolvedMyDocuments": my_documents(), "httpStatus": None})
        (out / "collector-report.json").write_text(json.dumps(collected, indent=2), encoding="utf-8")
        return 2
    client = Client(pat)
    try:
        for bid in args.build:
            b, _ = client.get(f"/_apis/build/builds/{bid}", {"api-version": API})
            tl, _ = client.get(f"/_apis/build/builds/{bid}/timeline", {"api-version": API})
            logs = log_signals(client, bid)
            records = tl.get("records", [])
            item = {"id": bid, "status": b.get("status"), "result": b.get("result"), "sourceVersion": b.get("sourceVersion"), "sourceBranch": b.get("sourceBranch"), "definition": (b.get("definition") or {}).get("name"), "repository": b.get("repository"), "buildUriCandidates": {"uri": b.get("uri"), "self": (b.get("_links") or {}).get("self", {}).get("href")}, "timeline": [{"name": x.get("name"), "type": x.get("type"), "state": x.get("state"), "result": x.get("result"), "recordId": x.get("id"), "logId": ((x.get("log") or {}).get("id"))} for x in records], "timelineSignals": timeline_signals(records), "logSignals": logs}
            item["jmx"] = jmx_evidence(client, item)
            collected["builds"].append(item)
            build_uri = f"vstfs:///Build/Build/{bid}"
            if build_uri:
                discovered, provenance = discover_runs(client, build_uri)
                provenance["buildId"] = bid; provenance["buildUriUsed"] = build_uri
                collected["runDiscovery"].append(provenance)
                for run in discovered:
                    rid = run.get("id")
                    if rid is None: continue
                    collected["runIds"].append(rid)
                    detail, _ = client.get(f"/_apis/test/runs/{rid}", {"api-version": API})
                    run_build = detail.get("build") if isinstance(detail.get("build"), dict) else {}
                    explicit = run_build.get("uri") or detail.get("buildUri")
                    if not run_matches_build(detail, bid):
                        collected["errors"].append({"classification": "run-build-contradiction", "buildId": bid, "runId": rid, "runBuildId": run_build.get("id"), "runBuildUri": explicit, "expectedBuildUri": build_uri})
                        continue
                    run = detail
                    run["discoveryBuildId"] = bid
                    run["discoveryBuildUri"] = build_uri
                    run["discoveryResponse"] = {"id": detail.get("id"), "name": detail.get("name"), "build": detail.get("build"), "buildUri": detail.get("buildUri")}
                    results, pages = client.pages(f"/_apis/test/runs/{rid}/results")
                    attachments, apages = client.pages(f"/_apis/test/runs/{rid}/attachments")
                    item = analyze(run, results, pages, attachments, apages)
                    item["buildUri"] = detail.get("build", {}).get("uri") if isinstance(detail.get("build"), dict) else detail.get("buildUri")
                    item["discoveryBuildId"] = bid
                    item["discoveryBuildUri"] = build_uri
                    item["runBuildFields"] = {"build": detail.get("build"), "buildUri": detail.get("buildUri")}
                    explicit = item["buildUri"]
                    item["buildUriMatches"] = [bid]
                    item["attributionVerdict"] = "FACT"
                    collected["testRuns"].append(item)
        # Empty discovery responses are retained in runDiscovery; no synthetic run is created.
    except requests.RequestException as e:
        collected["errors"].append({"classification": "http-or-transport", "httpStatus": getattr(e.response, "status_code", None), "message": str(e)[:300]})
    except Exception as e:
        collected["errors"].append({"classification": "collector-error", "httpStatus": None, "message": str(e)[:300]})
    finally:
        collected["http"] = client.events
        client.s.close()
        del pat
    by = {int(x["runId"]): x for x in collected["testRuns"]}
    for a, b in [(6189960,6185925),(6189957,6185924),(6189960,6189957),(6188849,6185925),(6188843,6185924)]:
        if a in by and b in by: collected["comparisons"].append(compare(by[a], by[b]))
    for bid in args.build:
        b = next((x for x in collected["builds"] if x["id"] == bid), None)
        rs = [x for x in collected["testRuns"] if bid in x.get("buildUriMatches", []) and x.get("attributionVerdict") == "FACT"]
        prov = next((x for x in collected["runDiscovery"] if x.get("buildId") == bid), None)
        collected["verdicts"].append({"buildId": bid,
            "discoveryVerdict": discovery_verdict(prov, len(rs)), "stagesJmeter": b.get("timelineSignals", {}) if b else "UNKNOWN", "testRunsByBuildUri": "FACT" if rs and all(x["attributionVerdict"] == "FACT" for x in rs) else ("UNKNOWN" if prov and prov.get("responseCount", 0) else "UNKNOWN"),
            "curFixCounts": variant_counts(rs),
            "jmxRuntimeConsumption": "UNKNOWN", "cleanupObserved": b["logSignals"].get("cleanupSignals", []) if b else "UNKNOWN",
            "basis": "fresh build/timeline/log/test-run REST reads; missing evidence remains UNKNOWN"})
    (out / "collector-report.json").write_text(json.dumps(collected, indent=2), encoding="utf-8")
    print(json.dumps({"builds": len(collected["builds"]), "runs": len(collected["testRuns"]), "httpEvents": len(collected["http"]), "errors": collected["errors"], "verdicts": collected["verdicts"]}, indent=2))
    return 0 if not collected["errors"] else 3

if __name__ == "__main__":
    sys.exit(main())
