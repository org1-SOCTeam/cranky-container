# Branching Strategy & Deployment

How code flows from development to production using branch-based deployments.

---

## 🌳 Git Flow Overview

```
feature/* branches
  ↓ (create PR to develop)
develop branch (staging)
  ↓ auto-deploy to GCP (staging-vm)
  ↓ (manual promotion to main)
main branch (production)
  ↓ auto-deploy to GCP (prod-vm)
  ↓
🎉 Live in production
```

---

## 📋 Branches Explained

### 1. **Feature Branches** (`feature/*`, `fix/*`, `docs/*`)

**Purpose:** Develop individual features, bug fixes, or documentation

**Naming:**
```bash
feature/add-health-check          # New feature
fix/resolve-timeout-bug           # Bug fix
docs/update-readme                # Documentation
refactor/optimize-queries         # Code refactor
```

**Workflow:**
```bash
# Create from develop (staging branch)
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# ... make changes, test locally ...

git add .
git commit -m "feat: add new endpoint"
git push origin feature/my-feature

# Open PR on GitHub (develop ← feature/my-feature)
```

**Protection Rules:** None (anyone can push)

---

### 2. **Develop Branch** (Staging)

**Purpose:** Integration point for features before production

**Characteristics:**
- Semi-stable (tested but early)
- Direct auto-deployment to staging server
- Code review required before merge
- CI/CD runs on every push/PR

**Workflow:**
```
feature branch → PR to develop
  ↓ (code review + tests)
Merge to develop
  ↓ (automatic)
Tests run on develop
  ↓ (automatic)
Auto-deploy to GCP staging (http://34.21.136.25:8001)
```

**Deployment:** Auto (immediate on merge)

**Environment:** Staging (GCP VM)
- Server: `ubuntu-cicd-vm` (34.21.136.25)
- Port: 8001
- For: Testing by team, QA verification

**Protection Rules:**
- ✅ Require pull request review (1 approval)
- ✅ Require status checks pass (CI tests)
- ✅ Require branches up to date

---

### 3. **Main Branch** (Production)

**Purpose:** Production-ready code only

**Characteristics:**
- Stable (thoroughly tested)
- Requires explicit merge (protected)
- Manual merge from develop
- Auto-deployment to production

**Workflow:**
```
develop branch (stable after testing)
  ↓ (create PR manually: main ← develop)
Code review + approval
  ↓ (1-2 reviewers)
Merge to main
  ↓ (automatic)
Tests run again
  ↓ (automatic)
Auto-deploy to prod (GCP)
  ↓ (if prod VM running)
```

**Deployment:** Auto (on merge to main)

**Environment:** Production (GCP VM)
- Server: `prod-satuck-vm` (34.128.100.109)
- Port: 8000
- For: Live users

**Protection Rules:**
- ✅ Require pull request review (2 approvals recommended)
- ✅ Require status checks pass (CI + tests)
- ✅ Require branches up to date
- ✅ Dismiss stale reviews (if code changes after approval)
- 🔒 **Admin only:** Can override protections (for emergencies)

---

## 🚀 Typical Workflow (Example)

### Day 1: Feature Development

```bash
# Developer works on new endpoint
git checkout -b feature/add-metrics-endpoint
# ... code, test locally, commit ...
git push origin feature/add-metrics-endpoint

# Open PR on GitHub
# → Automated tests run
# → Code review requested
```

**On GitHub:**
- Tests pass ✅
- Security scan passes ✅
- Colleague reviews + approves ✅

### Day 1 Evening: Merge to Develop

```bash
# Merge PR (on GitHub UI)
# → Auto-triggers develop deployment

Staging Workflow:
  ✅ Tests run again
  ✅ Security scan runs
  ✅ Container built
  ✅ Deployed to GCP staging (34.21.136.25:8001)
  ✅ Health check passes

Result: Staging is now updated
```

**Team tests staging:**
- QA team tests new feature
- Confirms it works
- Looks good!

### Day 2: Promote to Production

```bash
# Create PR: main ← develop
git checkout main
git pull origin main
git merge develop
# OR via GitHub UI:
# - New PR: main ← develop
# - Add description: "Release v1.2.0: Add metrics endpoint"
# - Request review from 2 team leads
```

**Code Review:**
- Lead A reviews: ✅ Approved
- Lead B reviews: ✅ Approved

### Day 2 Evening: Merge to Main

```bash
# Merge PR (on GitHub UI)
# → Auto-triggers production deployment

Production Workflow:
  ✅ Start prod VM (if not running)
  ✅ Tests run again
  ✅ Security scan runs
  ✅ Container built
  ✅ Deployed to GCP prod (34.128.100.109:8000)
  ✅ Health check passes
  ✅ Live to users!

Result: Production is updated
```

---

## 🚨 Deployment Statuses

### Develop → Staging

```
Push to develop
  ↓
CI Tests Run
  ├─ ✅ Unit tests pass
  ├─ ✅ Linting passes
  ├─ ✅ Security scan passes
  └─ ✅ Docker builds
  ↓
Deploy Staging Workflow Runs
  ├─ ✅ SSH into GCP VM
  ├─ ✅ Pull Docker image
  ├─ ✅ Stop old container
  ├─ ✅ Start new container
  └─ ✅ Health check passes
  ↓
✅ Staging Updated
(team can test immediately)
```

### Main → Production

```
Merge to main
  ↓
CI Tests Run (again)
  ├─ ✅ Unit tests pass
  ├─ ✅ Security scan passes
  └─ ✅ Docker builds
  ↓
Deploy Prod Workflow Runs
  ├─ ✅ Start prod VM
  ├─ ✅ SSH into prod VM
  ├─ ✅ Backup previous version
  ├─ ✅ Pull Docker image
  ├─ ✅ Stop old container
  ├─ ✅ Start new container
  ├─ ✅ Health check passes
  └─ ✅ Cleanup old backups
  ↓
✅ Production Updated
(live to users)
```

---

## 🔄 Reverting Changes

### If Staging Needs Rollback

```bash
# Revert the problematic PR
git checkout develop
git revert <commit-hash>
git push origin develop

# Staging auto-redeploys with previous version
```

### If Production Needs Rollback

```bash
# Create revert PR
git checkout main
git revert <commit-hash>
# Push as new branch
git push origin revert-commit-xyz

# Open PR to main
# After review + approval, merge
# → Auto-deploys reverted version
```

**Or manual rollback (emergency):**
```bash
# SSH to prod VM and restart old backup container
gcloud compute ssh prod-satuck-vm \
  --zone=asia-southeast2-a \
  --command="docker ps -a | grep cranky-prod-backup"
```

---

## 📊 Branch Protection Rules (GitHub Settings)

### Develop Branch

**Path:** Repo → Settings → Branches → Add rule for `develop`

```
✅ Require a pull request before merging
   └─ Required number of approvals: 1
✅ Require status checks to pass before merging
   └─ ci (Test suite)
   └─ security-scan (Dependency + SAST)
✅ Require branches to be up to date before merging
⚪ Require code owner review (optional)
⚪ Require signed commits (optional)
```

### Main Branch

**Path:** Repo → Settings → Branches → Add rule for `main`

```
✅ Require a pull request before merging
   └─ Required number of approvals: 2 (recommended)
✅ Require status checks to pass before merging
   └─ ci (Test suite)
   └─ security-scan (Dependency + SAST)
✅ Require branches to be up to date before merging
✅ Include administrators (for safety)
✅ Require code owner review (optional)
✅ Require signed commits (recommended for prod)
```

---

## 🔑 Common Commands

```bash
# Start new feature from develop
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Push feature branch
git push origin feature/my-feature

# Update feature with latest develop
git fetch origin
git rebase origin/develop

# Merge develop into main (locally, before PR)
git checkout main
git pull origin main
git merge develop
git push origin main

# View commit history
git log --graph --decorate --oneline origin/main origin/develop

# Check which branch you're on
git branch -v
```

---

## 📈 Metrics Per Branch

### Develop (Staging)
- Deploy frequency: Every time PR is merged (multiple per day)
- Lead time: ~30 minutes (commit to staging)
- Environment: Staging (non-prod, okay to break sometimes)
- QA can test immediately

### Main (Production)
- Deploy frequency: Once per day (or less, after testing in staging)
- Lead time: ~2-3 hours (commit to live users)
- Environment: Production (zero breakage tolerance)
- All users can access

---

## 🚦 Decision Tree: Which Branch?

**"I'm starting new work"**
→ Create feature branch from `develop`

**"My feature is ready for team testing"**
→ Create PR: develop ← feature/my-feature
→ Merge after approval
→ Wait for staging deployment

**"Staging looks good, ready for users"**
→ Create PR: main ← develop
→ Request review from 2 people
→ Merge after 2 approvals
→ Wait for prod deployment

**"I found a bug in production"**
→ Create `hotfix/` branch from `main`
→ Fix + test
→ PR to `main` (fast-track approval)
→ Also merge back to `develop`

**"I need to rollback production"**
→ Create revert PR to `main`
→ Approve + merge
→ Auto-reverts to previous version

---

## 🎯 Summary Table

| Aspect | Develop | Main |
|--------|---------|------|
| Purpose | Integration + testing | Production |
| Stability | Semi-stable | Very stable |
| Protection | 1 review required | 2 reviews required |
| Deployment | Auto on merge | Auto on merge |
| Environment | Staging (GCP) | Production (GCP) |
| Audience | Team + QA | Live users |
| Frequency | Multiple per day | Once daily (or less) |
| Downtime cost | Low | Very high |

---

## ✅ Checklist Before Merging

### Before merging feature → develop:
- [ ] Tests pass locally
- [ ] Tests pass in CI
- [ ] Security scan passes
- [ ] Code review approved (1 person)
- [ ] Branch is up to date with develop
- [ ] No conflicts

### Before merging develop → main:
- [ ] Feature tested in staging (3-5 days)
- [ ] No bugs reported in staging
- [ ] Tests pass in CI
- [ ] Security scan passes
- [ ] Code review approved (2 people)
- [ ] Branch is up to date with main
- [ ] Release notes documented
- [ ] No conflicts

---

**Ready to ship! 🚀**
