import csv, io, os, zipfile, requests, hashlib, xml.etree.ElementTree as ET

out = os.environ["W9_OUT"]
urls = os.environ["W9_URLS"].split("|")
session = requests.Session()
session.auth = ("", os.environ["W9_PAT"])
session.verify = True
summary = []
projections = {}
for url in urls:
    outer = zipfile.ZipFile(io.BytesIO(session.get(url, timeout=120).content))
    for outer_name in outer.namelist():
        if not outer_name.lower().endswith(".zip"):
            continue
        variant = "Fix" if "v26-Fix" in outer_name else "Cur"
        inner = zipfile.ZipFile(io.BytesIO(outer.read(outer_name)))
        rows = []
        for name in inner.namelist():
            if name.lower().endswith("-errors.csv"):
                error_rows = []
                reader = csv.DictReader(io.StringIO(inner.read(name).decode("utf-8-sig", "replace"), newline=""), delimiter=";")
                for row in reader:
                    if None in row:
                        continue
                    plan = row.get("TestPlan", "") or ""
                    tc = row.get("TestCase", "") or ""
                    op = row.get("Operation", "") or ""
                    oe = row.get("OpError", "") or ""
                    xe = row.get("XmlResError", "") or ""
                    sig = "SQLIncorrectSyntax" if ("incorrect syntax" in oe.lower() or "sqlserverexception" in oe.lower()) else ("XmlDifference" if "differences were found" in xe.lower() else "Other")
                    error_rows.append((plan, tc, op, sig))
                projections.setdefault(variant + "Errors", []).extend(error_rows)
                continue
            if not name.lower().endswith(".jtl"):
                continue
            raw = inner.read(name)
            digest = hashlib.sha256(raw).hexdigest().upper()
            text = raw.decode("utf-8-sig", "replace")
            count = 0
            plan = name.split("/")[-2]
            try:
                root = ET.fromstring(raw)
                for case in root.iter("testcase"):
                    count += 1
                    label = case.attrib.get("name", "")
                    success = "false" if case.find("error") is not None else "true"
                    failure = "" if case.find("error") is None else (case.find("error").attrib.get("message", "") or "")
                    sig = "SQLIncorrectSyntax" if "Incorrect syntax" in failure else ("XmlDifference" if "differences were found" in failure else "")
                    rows.append((plan, label, success, sig))
            except ET.ParseError:
                # JMeter CSV JTL: project only fixed columns before payload.
                for line in text.splitlines()[1:]:
                    parts = line.split(",")
                    if len(parts) < 8:
                        continue
                    count += 1
                    label = parts[2]
                    success = parts[7]
                    failure = parts[8] if len(parts) > 8 else ""
                    sig = "SQLIncorrectSyntax" if "Incorrect syntax" in failure else ("XmlDifference" if "differences were found" in failure else "")
                    rows.append((plan, label, success, sig))
            summary.append(f"{variant}\t{name}\trows={count}\tsha256={digest}")
        projections.setdefault(variant, []).extend(rows)
for variant, rows in projections.items():
    unique = sorted(set(rows))
    counts = {}
    for _, _, _, sig in rows:
        counts[sig or "Other"] = counts.get(sig or "Other", 0) + 1
    suffix = "-error-projection.tsv" if variant.endswith("Errors") else "-jtl-projection.tsv"
    with open(os.path.join(out, variant.replace("Errors", "") + suffix), "w", encoding="utf-8") as handle:
        handle.write("plan\tlabel\tsuccess\tsignature\n")
        for plan, label, success, sig in unique:
            handle.write(f"{plan}\t{label}\t{success}\t{sig}\n")
    with open(os.path.join(out, variant.replace("Errors", "") + "-jtl-summary.txt"), "w", encoding="utf-8") as handle:
        handle.write(f"rows={len(rows)} unique_plan_label_success_signature={len(unique)} counts={counts}\n")
with open(os.path.join(out, "jtl-direct-summary.txt"), "w", encoding="utf-8") as handle:
    handle.write("\n".join(summary) + "\n")
