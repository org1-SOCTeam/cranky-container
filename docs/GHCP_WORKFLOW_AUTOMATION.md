# GitHub Workflow Automation

Understanding how the CI/CD pipelines work behind the scenes.

---

## 🔄 Workflow Overview

This repo has **3 automated workflows** that run on GitHub:

```
┌─────────────────────────────────────────────────────────────┐
│                     Developer Pushes Code                    │
└────────────────┬────────────────────────────────────────────┘
                 │
        ┌────────▼────────┐
        │ 1. CI Workflow  │  (ci.yml)
        │                 │
        │ ✓ Run tests     │
        │ ✓ Lint code     │
        │ ✓ Build image   │
        └────────┬────────┘
                 │
        ┌────────▼─────────────┐
        │ 2. Security Scan     │  (security-scan.yml)
        │                      │
        │ ✓ Scan dependencies  │
        │ ✓ SAST analysis      │
        │ ✓ Secret detection   │
        └────────┬─────────────┘
                 │
        ┌────────▼──────────────┐
        │ 3. Deploy to Azure    │  (deploy-azure.yml)
        │                       │
        │ ✓ Push to registry    │  (only main branch)
        │ ✓ Deploy to Azure     │
        │ ✓ Health check        │
        │ ✓ Rollback on failure │
        └───────────────────────┘
```

---

## 📋 Workflow 1: CI — Tests & Linting

**File:** `.github/workflows/ci.yml`

**When it runs:**
- On every push to any branch
- On every pull request
- On push to main/develop

**Jobs:**

### Job 1: `test` — Unit Tests & Linting

```yaml
runs-on: ubuntu-latest
steps:
  1. Checkout code (clone the repo)
  2. Set up Python 3.11
  3. Install dependencies (requirements.txt)
  4. Run pytest (unit tests)
  5. Run pylint (code style)
  6. Run black (format check)
```

**Output:**
```
✅ All tests passed (15 tests)
✅ Linting score: 8.5/10
⚠️  2 style warnings (auto-fixable)
```

**If tests fail:**
```
❌ test_greet_alice FAILED
  assert "Hello, Alice!" == "Hello, alice!"
  
Fix: Capitalize greeting in code
Then: Push commit to same branch
Then: Tests re-run automatically
```

### Job 2: `security` — SAST & Secret Scanning

```yaml
runs-on: ubuntu-latest
steps:
  1. Checkout code
  2. Set up Python 3.11
  3. Install dependencies
  4. Run Bandit (security analysis)
  5. Detect secrets
```

**Output:**
```
⚠️  Potential hardcoded password on line 42
   severity: high
   severity: high
   line: password = "admin123"
```

### Job 3: `build` — Docker Build

```yaml
runs-on: ubuntu-latest
needs: [test, security]  # Only runs if tests pass
steps:
  1. Checkout code
  2. Build Docker image
  3. Test image runs successfully
```

**Output:**
```
docker build -t cranky-container:abc123 .
Step 1/8: FROM python:3.11-slim
Step 2/8: WORKDIR /app
...
Successfully tagged cranky-container:abc123
✅ Docker health check passed
```

---

## 🔒 Workflow 2: Security Scan — Dependencies & Code Analysis

**File:** `.github/workflows/security-scan.yml`

**When it runs:**
- On push to main/develop
- On pull request to main/develop
- Daily at 2 AM UTC (scheduled)

**Jobs:**

### Job 1: `dependency-check` — Vulnerable Packages

```yaml
tools: safety, pip-audit
checks:
  - For each installed package
  - Check against known CVE database
  - Report outdated packages
```

**Output:**
```
✓ Safety check
  All dependencies are safe

✓ Pip audit
  Found 0 packages with known vulnerabilities
```

### Job 2: `sast-scan` — Static Code Analysis

```yaml
tools: Bandit, Semgrep
checks:
  - Hardcoded credentials
  - SQL injection risks
  - Insecure crypto usage
  - Command injection
  - Path traversal
```

**Example detection:**
```python
# Line 45: db.execute(f"SELECT * FROM users WHERE id = {id}")
# Issue: SQL injection vulnerability
# CWE-89: Improper Neutralization of Special Elements used in an SQL Command
# Fix: Use parameterized queries
```

### Job 3: `secret-scan` — Credentials Detection

```yaml
checks:
  - Look for SSH keys, API keys, tokens
  - Scan commit history
  - Check for common patterns (password=, secret=)
```

### Job 4: `container-scan` — Docker Image Vulnerabilities

```yaml
tool: Trivy
checks:
  - Build Docker image
  - Scan base image (python:3.11-slim) for CVEs
  - Scan installed packages
```

**Example output:**
```
Scanning image 'cranky-container:latest' for vulnerabilities...

libssl3 (Debian)
├─ CVE-2023-2650 [HIGH]
│  └─ Introduced by: libssl3 3.0.8-1 in base image
│     └─ Can be fixed by updating base image to 3.0.10
└─ ...

Total: 2 vulnerabilities
  - CRITICAL: 0
  - HIGH: 2  ⚠️
  - MEDIUM: 1
```

### Job 5: `license-check` — Dependency Licensing

```yaml
checks:
  - Scans all dependencies
  - Checks licenses (MIT, Apache, GPL, etc.)
  - Warns on restrictive licenses (AGPL, etc.)
```

**Output:**
```
fastapi               3.109.0     MIT
uvicorn              0.27.0      BSD
pydantic             2.5.3       MIT
pytest               7.4.4       MIT

All licenses are permissive ✅
```

---

## 🚀 Workflow 3: Deploy to Azure

**File:** `.github/workflows/deploy-azure.yml`

**When it runs:**
- Only on push to main branch (not develop or feature branches)
- Can be triggered manually via `workflow_dispatch`

**Prerequisites:**
```
GitHub Secrets (configured):
  - AZURE_CREDENTIALS    (Service Principal)
  - AZURE_REGISTRY_URL   (Container Registry URL)
  - AZURE_REGISTRY_USERNAME
  - AZURE_REGISTRY_PASSWORD
```

### Job 1: `build` — Build & Push Image

```yaml
steps:
  1. Checkout code
  2. Log in to Azure Container Registry
  3. Build Docker image with tags:
     - Branch name: main
     - Commit SHA: abc123def
  4. Push to registry (Azure Container Registry)
```

**Output:**
```
Building image: cranky-container:main
Adding tag: cranky-container:main-abc123def
Pushing to registry: myregistry.azurecr.io/cranky-container
✅ Image pushed successfully
```

### Job 2: `test-deployment` — Verify Image

```yaml
needs: build  # Waits for build to complete
steps:
  1. Pull the image from registry
  2. Run container
  3. Execute tests inside container
  4. Verify health check passes
```

**Output:**
```
Running tests in Docker container...
15 passed in 2.34s
✅ All tests passed in deployment image
```

### Job 3: `deploy-function` — Deploy to Azure Function

```yaml
needs: [build, test-deployment]  # Only if previous jobs pass
steps:
  1. Login to Azure
  2. Deploy to Azure Function App
  3. Set environment variables
  4. Wait for deployment
```

**Output:**
```
Deploying to: cranky-container-func.azurewebsites.net
Starting deployment...
Deploying application...
Deployment completed successfully ✅
```

### Job 4: `deploy-vm` — Deploy to Azure VM

```yaml
steps:
  1. Login to Azure
  2. SSH into VM (via Azure CLI)
  3. Stop old container
  4. Pull new image
  5. Start new container with env vars
```

**Output:**
```
Connecting to cranky-container-vm...
Stopping old container...
Pulling new image...
Starting new container (cranky-container:main)
✅ Container running on VM
```

### Job 5: `health-check` — Verify Live

```yaml
needs: [deploy-function, deploy-vm]
steps:
  1. Make HTTP request to /health endpoint
  2. Verify 200 status code
  3. Test all endpoints work
  4. Retry 5 times if failed
```

**Output:**
```
Checking health endpoint...
  Attempt 1: ⏳ Waiting...
  Attempt 2: ✅ 200 OK
Checking API endpoints...
  GET /greet/Workshop → 200 OK ✅
  POST /echo → 200 OK ✅
  GET /metrics → 200 OK ✅
All endpoints healthy! ✅
```

### Job 6: `rollback` — If Deployment Fails

```yaml
if: failure()  # Only runs if previous jobs failed
steps:
  1. Login to Azure
  2. Swap staging slot with production
  3. Revert to previous working version
```

**Output:**
```
⚠️  Deployment failed. Rolling back...
Swapping slots: staging ↔ production
🔄 Reverted to previous version
Previous version is now live again
```

---

## 📊 Reading Workflow Logs

### On GitHub UI

1. **Go to repo → Actions tab**
2. **Click the workflow run** (titled with commit message)
3. **Click job name** to see details
4. **Click step** to expand output

**Example:**
```
workflow: CI — Tests & Linting
triggered by: push to feature/add-endpoint

✅ test (completed in 2m 45s)
  ✅ Checkout code (5s)
  ✅ Set up Python (10s)
  ✅ Install dependencies (45s)
  ✅ Run pytest (1m 30s)
  ✅ Lint with pylint (10s)
  ✅ Format check with black (5s)

✅ security (completed in 1m 30s)
  ✅ Bandit (45s)
  ✅ Secret detection (45s)

✅ build (completed in 3m 15s)
  ✅ Build Docker image (3m 15s)
```

### Via CLI

```bash
# List recent workflow runs
gh run list --repo <org>/<repo>

# View specific run
gh run view <run-id>

# Watch run in real-time
gh run watch <run-id>

# View job logs
gh run view <run-id> --log-failed
```

---

## 🔧 Customizing Workflows

### Add a new test step

```yaml
# In .github/workflows/ci.yml

- name: Run integration tests
  run: |
    pytest tests/integration/ -v --tb=short
```

### Add a new deployment environment

```yaml
# In .github/workflows/deploy-azure.yml

deploy-staging:
  name: Deploy to Azure Staging
  needs: [build, test-deployment]
  environment:
    name: staging
    url: https://staging-cranky-func.azurewebsites.net
  steps:
    # Similar to deploy-function but with staging credentials
```

### Trigger workflow on schedule

```yaml
# Run tests daily at 9 AM UTC
on:
  schedule:
    - cron: '0 9 * * *'
```

---

## 🚨 Troubleshooting

### "Tests failed"

**Check the logs:**
```bash
gh run view --log-failed
# or browse GitHub UI → Actions → failed run
```

**Fix:**
```bash
# Run tests locally first
pytest tests/ -v

# Fix the issue
nano src/main.py

# Commit + push (tests run again automatically)
git commit -m "fix: address test failure"
git push origin feature/my-feature
```

### "Deployment failed"

**Check health check logs:**
```
❌ Health check failed after 5 attempts
  curl https://cranky-func.azurewebsites.net/health → no response

Possible causes:
  - Container didn't start (check logs)
  - Port not exposed (check Dockerfile)
  - Environment variables missing (check deploy workflow)

Action: Check Azure Function logs
  az webapp log tail --resource-group cranky-rg --name cranky-container-func
```

### "Secrets not found"

**Error:** `AZURE_CREDENTIALS not found`

**Fix:**
1. Go to GitHub repo → Settings → Secrets and variables → Actions
2. Add missing secrets:
   - AZURE_CREDENTIALS
   - AZURE_REGISTRY_URL
   - etc.

---

## 📚 Related Docs

- [Developer Lifecycle](DEVELOPER_LIFECYCLE.md) — How to use these workflows
- [DORA Metrics](DORA_METRICS_GUIDE.md) — Measuring impact
- [DevSecOps Best Practices](DEVSECOPS_BEST_PRACTICES.md) — Security gates explained

---

**Workflows run automatically. You don't need to trigger them manually. Just push code and watch the magic happen! ✨**
