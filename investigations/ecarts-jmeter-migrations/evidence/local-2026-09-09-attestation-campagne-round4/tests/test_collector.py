import importlib.util

spec = importlib.util.spec_from_file_location("collector", "scripts/invoke_bw3_collector.py")
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)

def test_timeline_distinguishes_runner_and_skipped():
    x = c.timeline_signals([
        {"id": "s", "type": "Stage", "name": "JMeter", "state": "completed", "result": "succeeded"},
        {"id": "r", "type": "Task", "name": "Run Jmeter Tests Campaign Cur", "state": "completed", "result": "succeeded"},
        {"id": "t", "type": "Task", "name": "Run Jmeter Tests Campaign Fix", "state": "skipped", "result": "skipped"},
    ])
    assert x["runnerExecuted"] is True and x["jmeterSkipped"] is True
    assert x["runnerRecords"][0]["recordId"] == "r"

def test_prepare_jmeter_is_not_runner_evidence():
    x = c.timeline_signals([{"id": "p", "type": "Task", "name": "Prepare Jmeter Campaign Run Cur", "state": "completed", "result": "succeeded"}])
    assert x["runnerExecuted"] is False and x["runJmeterTasks"] == []

def test_cleanup_is_structured_observation_not_boolean():
    # The collector contract stores logId, line, operation, result and scope.
    sample = {"logId": 7, "line": 12, "operation": "docker rm abc", "resultObserved": "reported-success-or-benign", "scope": "UNKNOWN"}
    assert set(sample) == {"logId", "line", "operation", "resultObserved", "scope"}

def test_incomplete_pages_are_not_complete():
    run = {"id": 1, "name": "X-Cur", "state": "completed"}
    x = c.analyze(run, [], [{"count": 1000, "complete": False}], [], [])
    assert x["total"] == 0 and x["resultsComplete"] is False

def test_duplicate_result_ids_are_incomplete():
    run = {"id": 1, "name": "X-Cur", "state": "completed", "totalTests": 2}
    results = [{"id": 7, "testCaseTitle": "a", "outcome": "Passed"}, {"id": 7, "testCaseTitle": "b", "outcome": "Passed"}]
    x = c.analyze(run, results, [{"count": 2, "complete": True}], [], [])
    assert x["resultIdsUnique"] is False and x["resultsComplete"] is False

def test_run_build_contradiction_is_rejected():
    assert c.run_matches_build({"build": {"id": 4432554}}, 4432554) is True
    assert c.run_matches_build({"build": {"id": 2054}}, 4432554) is False
    assert c.run_matches_build({"buildUri": "vstfs:///Build/Build/2054"}, 4432554) is False
    assert c.run_matches_build({"build": {"id": "not-an-id"}}, 4432554) is False

def test_discovery_verdict_branches():
    assert c.discovery_verdict({"pages": [{"complete": True}], "responseCount": 0}, 0) == "complete-empty"
    assert c.discovery_verdict({"pages": [{"complete": False}], "responseCount": 1}, 0) == "discovery-incomplete"
    assert c.discovery_verdict({"pages": [{"complete": True}], "responseCount": 1}, 0) == "all-runs-rejected"
    assert c.discovery_verdict({"pages": [{"complete": True}], "responseCount": 1}, 1) == "attribution-valid"

def test_variant_absence_or_incomplete_returns_null():
    assert c.variant_counts([]) == {"Cur": None, "Fix": None}
    assert c.variant_counts([{"name": "Other", "total": 3, "resultsComplete": True}]) == {"Cur": None, "Fix": None}
    assert c.variant_counts([{"name": "X-Cur", "total": 3, "resultsComplete": False}]) == {"Cur": None, "Fix": None}
