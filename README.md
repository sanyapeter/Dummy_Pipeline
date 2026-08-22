# Pipeline Doctor — Dummy Pipeline & Failure Scenarios

A small, deliberately breakable app + CI pipeline for demoing Pipeline
Doctor. Five distinct, realistic failure modes, plus one "passed but
risky" scenario and one clean pass — enough variety for a live demo
without needing to improvise a real bug on stage.

## What's in here

```
app.py                          toy Flask app with a BREAK_MODE switch
requirements.txt                intentionally missing boto3
tests/test_app.py               unit test that can be toggled to fail
.github/workflows/ci.yml        GitHub Actions pipeline (manual BREAK_MODE picker)
Jenkinsfile                     same pipeline, Jenkins syntax
terraform/main.tf               intentionally over-permissioned IAM + security group
runbooks/                       docs for the RAG knowledge base (upload these to S3)
sample_failures/*.json          canned "structured event" payloads, ready to POST
                                 straight into your Lambda without running real CI
```

## The 6 scenarios

| Scenario | Trigger | Stage | What Pipeline Doctor should say |
|---|---|---|---|
| `missing_dep` | `BREAK_MODE=missing_dep` | BUILD | Missing boto3 in requirements.txt — safe to auto-fix |
| `failing_test` | `BREAK_MODE=failing_test` | TEST | Assertion mismatch — needs human review (could be a real regression) |
| `bad_config` | `BREAK_MODE=bad_config` | DEPLOY | Missing `DATABASE_URL` — needs human approval (secrets) |
| `slow_deploy` | `BREAK_MODE=slow_deploy` | DEPLOY | Health check timeout — safe to bump timeout, or escalate |
| `risky_iam_change` | edit `terraform/main.tf` (already risky as checked in) | passes, but flagged | Wildcard IAM + open security group — always needs approval |
| `clean_pass` | default, `BREAK_MODE=none` | — | Nothing to do, log and move on |

## Running it locally

```bash
pip install -r requirements.txt
BREAK_MODE=missing_dep python -c "import app"     # ModuleNotFoundError
BREAK_MODE=failing_test pytest tests/ -v          # AssertionError
BREAK_MODE=bad_config python app.py               # KeyError
```

## Running it in GitHub Actions

Push this repo to GitHub, then go to **Actions → CI Pipeline → Run workflow**
and pick a `break_mode` from the dropdown. Each run produces a real,
readable failure log you can feed to Pipeline Doctor via webhook.

## Running it in Jenkins

Point a Jenkins pipeline job at this repo (`Jenkinsfile` is at the root).
The build parameter `BREAK_MODE` gives you the same dropdown experience.

## Skipping live CI entirely (fastest path for a hackathon demo)

If you don't want to depend on a live GitHub Actions / Jenkins run during
judging, just POST the pre-built JSON files in `sample_failures/` directly
to your API Gateway endpoint — they're already shaped exactly like the
"Structured Event" your Lambda expects to parse. This lets you demo all
6 scenarios back-to-back in under a minute, with zero flake risk.

```bash
curl -X POST https://<your-api-gateway-url>/pipeline-event \
  -H "Content-Type: application/json" \
  -d @sample_failures/missing_dep.json
```

## Wiring up the RAG layer

Upload everything in `runbooks/` to your S3 bucket and point your Bedrock
Knowledge Base at it. Each file is written to closely match the wording
of its corresponding `sample_failures/*.json` error message, so retrieval
should reliably surface the right doc for each scenario — this is what
makes "Matched: runbook — Missing boto3 dependency" show up convincingly
in your demo instead of a generic AI guess.
