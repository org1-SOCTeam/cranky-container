# Developer Lifecycle: Code → Commit → Review → Deploy

## Overview

This guide walks developers through the **complete workflow** from writing code to deploying to production. This is what your team will do every day.

---

## 🔄 The Workflow (7 Steps)

```
┌─────────────────┐
│ 1. Start Branch │ (feature/my-feature)
└────────┬────────┘
         │
         v
┌─────────────────────────┐
│ 2. Code Locally + Test  │ (git add . && pytest)
└────────┬────────────────┘
         │
         v
┌──────────────────────────┐
│ 3. Commit + Push to GHE  │ (git commit && git push)
└────────┬─────────────────┘
         │
         v
┌──────────────────────────────┐
│ 4. Open PR + Auto Tests      │ (GitHub detects push)
│    ✓ Security scan runs      │
│    ✓ Linting + unit tests    │
└────────┬─────────────────────┘
         │
         v
┌──────────────────────────┐
│ 5. Code Review Required  │ (Colleague approves)
└────────┬─────────────────┘
         │
         v
┌──────────────────────────┐
│ 6. Merge to Main         │ (All checks passed)
└────────┬─────────────────┘
         │
         v
┌──────────────────────────────┐
│ 7. Auto Deploy to Azure      │ (GitHub workflow runs)
│    → Live in ~5 minutes      │
└──────────────────────────────┘
```

---

## 📋 Step-by-Step Details

### Step 1️⃣: Create a Feature Branch

**Why?** Keep main branch clean. Each feature gets its own branch.

```bash
# Make sure you're on latest main
git checkout main
git pull origin main

# Create feature branch (use clear naming)
git checkout -b feature/add-health-check
# or: git checkout -b fix/resolve-timeout-bug
# or: git checkout -b docs/update-readme
```

**Naming convention:**
- `feature/` — new functionality
- `fix/` — bug fix
- `docs/` — documentation
- `refactor/` — code improvement (no behavior change)

---

### Step 2️⃣: Write Code & Test Locally

**This is where you normally work.**

```bash
# Edit your files
nano src/main.py

# Test locally (example for Python)
python src/main.py
# Or: npm start (for Node)

# Run automated tests
pytest tests/
# Or: npm test

# Check code style
pylint src/main.py
# Or: eslint src/
```

**Key point:** Test locally BEFORE pushing. The automated checks will catch issues, but catching them locally saves time.

---

### Step 3️⃣: Commit & Push

**Stage your changes:**
```bash
git status  # See what changed

git add .   # Stage all changes
# Or selectively: git add src/main.py

git commit -m "feat: add health check endpoint"
```

**Commit message format (conventional commits):**
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation change
- `refactor:` code refactor
- `test:` test additions
- `ci:` CI/CD changes

**Push to GitHub:**
```bash
git push origin feature/add-health-check
```

**What happens automatically:**
- GitHub detects the push
- Creates a PR (if first push from this branch)
- Triggers automated workflows:
  - 🔍 Security scan
  - ✅ Tests
  - 📋 Linting

---

### Step 4️⃣: Automated Checks Run (PR Created)

**You don't need to do anything.** GitHub runs these automatically:

| Check | What It Does | Time | Pass/Fail |
|-------|--------------|------|-----------|
| **Unit Tests** | `pytest tests/` | ~2 min | Must pass |
| **Linting** | Code style check | ~30 sec | Must pass |
| **Security Scan** | Detects vulnerable deps | ~1 min | Warns (can override) |
| **Dependency Check** | Package vulnerabilities | ~1 min | Can warn/fail |

**In GitHub UI**, you'll see:
```
✅ All tests passed
⚠️  Security scan: 1 dependency warning (click to review)
✅ Code review: Awaiting approval
```

**If a check fails:**
```
❌ Tests failed (1 test failing)
→ Push a fix commit to the same branch
→ Tests re-run automatically
→ No need to create a new PR!
```

---

### Step 5️⃣: Code Review (Human Check)

**Your team reviews your code.** This is where knowledge sharing happens.

```
On GitHub PR page:
→ Team member clicks "Files changed"
→ Leaves comments on specific lines
→ Suggests improvements
→ Either approves or requests changes
```

**If changes requested:**
```bash
# Fix the issues locally
nano src/main.py

# Commit + push (same branch)
git add .
git commit -m "fix: address review feedback"
git push origin feature/add-health-check

# Your reviewer can re-review
# No new PR needed! Same PR updates automatically.
```

**Once approved:**
```
✅ Code review approved
(Merge button now active)
```

---

### Step 6️⃣: Merge to Main

**Click "Merge" button** on GitHub PR.

```
What happens:
1. Your code joins main branch
2. GitHub marks PR as closed
3. GitHub automatically deletes your feature branch
```

**Or via CLI:**
```bash
git checkout main
git pull origin main
git merge feature/add-health-check
git push origin main
```

---

### Step 7️⃣: Auto Deploy to Azure

**You don't do anything.** GitHub detects the merge and deploys.

```
Trigger: Code merged to main
  ↓
GitHub Workflow: deploy-azure.yml starts
  ↓
  1. Build Docker image
  2. Run final security scan
  3. Deploy to Azure Function/VM
  4. Verify health check
  ↓
✅ Deployed! Live in ~5 minutes
```

**Check deployment status:**
```
On GitHub:
→ Go to PR
→ Scroll down to "Deployments" section
→ Click Azure link to see live app
```

---

## 🚨 What Stops a Deploy?

Your code **won't merge** if:

❌ **Tests fail** → Fix the code locally + re-push
❌ **Security scan finds critical vulnerability** → Review + fix + re-push
❌ **Code review not approved** → Address feedback + get approval
❌ **Linting fails** → Auto-fix + re-push

```bash
# Auto-fix linting issues (example)
autopep8 --in-place src/main.py
git add .
git commit -m "style: auto-fix linting"
git push origin feature/add-health-check
```

---

## ⏱️ Timeline Example

**Real scenario: You add a new feature**

| Time | Action |
|------|--------|
| 10:00 | Create branch + code locally |
| 10:15 | Commit + push |
| 10:16 | GitHub PR created + tests start |
| 10:20 | ✅ Tests pass, colleague reviews |
| 10:25 | Colleague approves |
| 10:26 | You click merge |
| 10:27 | Deploy workflow starts |
| 10:32 | ✅ Deployed to Azure (live!) |

**Total: 32 minutes from start to production** ✨

---

## 🔗 Integration Checklist (For This Repo)

Before you start, make sure:

- [ ] You have access to this GitHub repo
- [ ] Your Git is configured with your name/email
  ```bash
  git config user.name "Your Name"
  git config user.email "your.email@company.com"
  ```
- [ ] You can run tests locally
  ```bash
  pip install -r requirements.txt
  pytest tests/
  ```
- [ ] You can see GitHub Actions logs (after first push)

---

## 🤔 FAQ

**Q: What if I accidentally committed something to main?**
A: The branch protection rule prevents direct push. Use a PR instead.

**Q: Can I skip code review?**
A: No. Approval is mandatory. This catches bugs early.

**Q: What if the security scan finds a warning but I think it's okay?**
A: Document in PR comment why it's acceptable. Reviewer can approve anyway.

**Q: How long until my code is live?**
A: ~5 minutes after merge (once deploy workflow completes).

**Q: Can I deploy without going through this flow?**
A: No. This is the only approved deployment method.

---

## 🎯 Key Differences from Manual Deployment

| Before (Manual) | After (This Workflow) |
|---|---|
| Dev codes locally, emails code to ops | Dev commits to GHE, auto-deploy |
| Ops manually tests on staging | Automated tests run on every push |
| Manual security review (slow) | Automated scanning + human review |
| Deploy takes 2 weeks, scary | Deploy takes 5 min, safe & fast |
| Hard to know what's in production | Git history shows exactly what's live |
| Rollback is manual (risky) | Can rollback via revert PR |

---

## Next: Understand the Automation

→ See [GitHub Workflow Automation](GHCP_WORKFLOW_AUTOMATION.md) to learn how the CI/CD pipelines work.

→ See [DORA Metrics](DORA_METRICS_GUIDE.md) to understand the impact you're creating.
