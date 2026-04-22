# Cranky Container — Quick Setup & Testing Guide

This file helps you set up the repo locally and verify everything works before the workshop.

---

## 📦 Prerequisites

Before you start:
- Python 3.11+ installed
- Git configured (name + email)
- Docker installed (for building images)
- Access to GitHub repo

---

## 🚀 Local Setup (5 minutes)

### 1. Clone the repo

```bash
git clone https://github.com/<org>/cranky-container.git
cd cranky-container
```

### 2. Create Python virtual environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Run the app locally

```bash
python src/main.py

# Output:
# INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

### 5. Test the API (in another terminal)

```bash
# Health check
curl http://localhost:8000/health

# Greeting
curl http://localhost:8000/greet/Workshop

# Metrics
curl http://localhost:8000/metrics

# API docs (open in browser)
# http://localhost:8000/docs
```

---

## ✅ Run Tests

```bash
pytest tests/ -v

# Output:
# test_main.py::TestHealth::test_health_check PASSED
# test_main.py::TestHealth::test_health_contains_timestamp PASSED
# test_main.py::TestRoot::test_root_endpoint PASSED
# ...
# 15 passed in 2.34s
```

---

## 🐳 Build Docker Image

```bash
docker build -t cranky-container:latest .

# Test the image
docker run --rm -p 8000:8000 cranky-container:latest
```

---

## 🔑 GitHub Setup (Before Workshop)

### 1. Create branch protection rules

**Go to:** Repo → Settings → Branches → Add rule

```
Branch name pattern: main

Require:
  ☑ Pull request reviews before merging (1 review)
  ☑ Status checks to pass before merging
  ☑ Branches to be up to date before merging
  ☑ Signed commits (optional, recommended)
```

### 2. Add GitHub Secrets (For Azure deploy)

**Go to:** Repo → Settings → Secrets and variables → Actions

Add these secrets:
```
AZURE_CREDENTIALS=<service principal JSON>
AZURE_REGISTRY_URL=<registry-name.azurecr.io>
AZURE_REGISTRY_USERNAME=<username>
AZURE_REGISTRY_PASSWORD=<password>
```

### 3. Configure CODEOWNERS (optional)

Create `.github/CODEOWNERS`:
```
# Everyone reviews Python code
src/         @username1 @username2

# DevOps reviews workflows
.github/     @devops-team
```

---

## 🧪 Test the Full Workflow (Optional, Before Workshop)

### Scenario: Make a small change and see it go through the workflow

**Step 1: Create a feature branch**
```bash
git checkout -b feature/test-workflow
```

**Step 2: Make a small change**
```bash
# Edit README or add a comment to main.py
nano src/main.py
```

**Step 3: Commit and push**
```bash
git add .
git commit -m "test: verify workflow execution"
git push origin feature/test-workflow
```

**Step 4: Watch the magic on GitHub**
- Go to repo → Pull requests
- Click the PR for your branch
- Watch "Checks" run (CI, security scan, build)
- All should pass ✅

**Step 5: Create a second commit to verify re-run**
```bash
nano src/main.py  # Make another small change
git add .
git commit -m "test: second change"
git push origin feature/test-workflow

# Watch checks re-run on GitHub
```

**Step 6: Request review and merge**
- Click "Review required" button
- Ask someone to approve (or approve yourself if admin)
- Click "Merge pull request"
- Watch deploy workflow run ✅

---

## 📊 Verify Workflows Are Working

### Check CI workflow

Go to: Repo → Actions → CI — Tests & Linting

Should show recent successful runs:
```
✅ Pushed by: <your-name>
   Time: 2 minutes ago
   Duration: 4 min 30 sec
```

Click a run to see:
- ✅ Test step (all tests pass)
- ✅ Linting step (code quality)
- ✅ Docker build step (image built)

### Check Security workflow

Go to: Repo → Actions → Security Scan

Should show:
```
✅ Dependency scan (no vulnerabilities)
✅ SAST scan (no critical issues)
✅ Secret scan (no secrets found)
✅ Container scan (no image vulnerabilities)
```

### Check Deploy workflow

Go to: Repo → Actions → Deploy to Azure

Expected (only runs on main branch):
```
✅ Build image
✅ Test deployment
✅ Deploy to Azure Function
✅ Deploy to Azure VM
✅ Health check
```

---

## 🐛 Troubleshooting

### Tests fail locally

```bash
# Make sure you're in the virtual environment
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Run tests again
pytest tests/ -v
```

### Docker build fails

```bash
# Check Docker is running
docker ps

# Try building with verbose output
docker build -t cranky-container:latest . --progress=plain
```

### Workflows not running on GitHub

**Check:**
1. Did you push to the repo?
   ```bash
   git push origin feature/my-branch
   ```

2. Do workflow files exist?
   ```bash
   ls -la .github/workflows/
   # Should show ci.yml, security-scan.yml, deploy-azure.yml
   ```

3. Are workflows enabled?
   Go to: Repo → Actions → check if workflows are enabled

4. Check for workflow syntax errors
   Go to: Repo → Actions → click workflow → see error details

---

## 📝 Pre-Workshop Checklist

Before 2026-04-23 (workshop day):

- [ ] Repo is cloned locally
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] App runs locally (python src/main.py)
- [ ] Tests pass locally (pytest tests/ -v)
- [ ] Docker image builds (docker build ...)
- [ ] Branch protection configured on main
- [ ] GitHub Secrets added (AZURE_CREDENTIALS, etc.)
- [ ] CI workflow runs on push (check Actions tab)
- [ ] Deploy workflow configured (check .github/workflows/)
- [ ] README is polished and clear
- [ ] All doc files are created (see ../docs/)
- [ ] Workshop script is prepared (docs/WORKSHOP_GUIDE.md)

---

## 🎯 What to Show During Workshop

### Demo Flow (Practice this!)

1. **Show the repo structure**
   - "Here's the application (src/main.py)"
   - "Here are the tests (tests/)"
   - "Here are the automation workflows (.github/workflows/)"

2. **Make a test change**
   ```bash
   git checkout -b demo/add-feature
   # Edit something small
   git add .
   git commit -m "demo: add feature"
   git push origin demo/add-feature
   ```

3. **Show PR on GitHub**
   - PR auto-created
   - Tests running in real-time
   - Security scan running

4. **Request review & merge**
   - Colleague approves (or you approve yourself)
   - Merge the PR
   - Deploy workflow starts automatically

5. **Show deployment success**
   - Check health endpoint
   - Show deployment logs

---

## 📚 Documentation Structure

Developers should read in this order:

1. **README.md** ← You are here (high-level overview)
2. **docs/DEVELOPER_LIFECYCLE.md** ← How to code + push + deploy (step-by-step)
3. **docs/DORA_METRICS_GUIDE.md** ← Why this matters (business impact)
4. **docs/DEVSECOPS_BEST_PRACTICES.md** ← Security gates explained
5. **docs/GHCP_WORKFLOW_AUTOMATION.md** ← How workflows work behind the scenes
6. **docs/WORKSHOP_GUIDE.md** ← Facilitation notes (for instructors)

---

## 🎓 During Workshop

**Use this repo as a live example:**
- Show them the developer workflow in action
- Let them push code and see CI/CD run
- Show deployment to Azure
- Discuss DORA metrics impact
- Answer questions about security gates

**Key messaging:**
- "Manual deployment: 2 weeks, risky, slow feedback"
- "This workflow: 5 min deploy, safe, fast feedback"
- "You can deploy 10x faster and with 10x more confidence"

---

## ❓ FAQ

**Q: Do I need Azure credentials to use this locally?**
A: No. Local testing doesn't need Azure. Deploy workflows only run on GitHub.

**Q: Can I modify the workflows?**
A: Yes! Workflows are YAML files in `.github/workflows/`. Edit and push.

**Q: What if a test fails?**
A: Fix it locally, commit, push. Tests re-run automatically.

**Q: How do I rollback a bad deployment?**
A: Create a revert PR, merge it. Auto-deploy rolls back.

**Q: Who has access to production?**
A: Only the auto-deploy workflow (no human SSH access).

---

## 📞 Support

- **Questions about workflow setup?** Check docs/ folder
- **Need to adjust workflows?** Edit .github/workflows/ YAMLs
- **Workshop script?** See docs/WORKSHOP_GUIDE.md
- **Technical issues?** Check GitHub Actions logs

---

**You're ready! Good luck with the workshop.** 🚀
