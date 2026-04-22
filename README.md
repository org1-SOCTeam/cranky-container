# Cranky Container — GHE DevSecOps Demo

A hands-on demo repository showing the **complete developer-to-cloud workflow** using GitHub Enterprise and automated CI/CD pipelines.

## 🎯 What This Shows

This repo demonstrates how development teams transition from manual deployment to automated CI/CD:

```
Local Dev → Code Review → Security Scan → Automated Deploy → DORA Metrics
```

**Before:** Manual testing + manual Azure deployment + security gaps + slow feedback
**After:** Automated gates, fast feedback loops, measurable quality (DORA metrics)

---

## 📊 Real-World Impact (DORA Metrics)

When you implement this workflow, your team typically sees:

| Metric | Impact | Evidence in This Repo |
|--------|--------|----------------------|
| **Deployment Frequency** | Deploy weekly instead of monthly | Auto-deploy on merge |
| **Lead Time for Changes** | 2 days instead of 2 weeks | PR → review → merge → live |
| **Mean Time to Recovery** | Auto-rollback on failed tests | Security scan gates merges |
| **Change Failure Rate** | 50% fewer prod bugs | Dependency scanning + SAST |

---

## 🚀 Quick Start

### For Developers

```bash
# 1. Clone & set up
git clone https://github.com/<org>/cranky-container.git
cd cranky-container

# 2. Create feature branch
git checkout -b feature/your-feature

# 3. Make changes & test locally
python src/main.py
# ... or: npm start

# 4. Commit + push
git add .
git commit -m "feat: add new endpoint"
git push origin feature/your-feature

# 5. Open PR on GitHub
# → Automated security scan runs
# → Code review gates merge
# → Auto-deploy on approval ✅
```

**Total time to production: ~15 min** (vs. 2 weeks manual)

### For Ops / DevOps

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for Azure VM/Function setup.

---

## 📚 Documentation

- **[Developer Lifecycle](docs/DEVELOPER_LIFECYCLE.md)** — Full walk-through (code → deploy)
- **[DORA Metrics](docs/DORA_METRICS_GUIDE.md)** — What we measure & why
- **[DevSecOps Best Practices](docs/DEVSECOPS_BEST_PRACTICES.md)** — Security checklist
- **[Workshop Guide](docs/WORKSHOP_GUIDE.md)** — Facilitation script + demo notes
- **[GitHub Workflow Automation](docs/GHCP_WORKFLOW_AUTOMATION.md)** — How the workflows work

---

## 🏗️ Repo Structure

```
cranky-container/
├── src/                      # Sample Python app (simple REST API)
│   ├── main.py              # FastAPI app
│   ├── Dockerfile           # Container image
│   └── requirements.txt      # Dependencies
├── .github/
│   └── workflows/           # GitHub Actions (CI/CD)
│       ├── ci.yml           # Test + lint
│       ├── security-scan.yml # SAST + dependency check
│       └── deploy-azure.yml # Auto-deploy to Azure
├── docs/                    # Best practices & guides
├── .gitignore
└── README.md
```

---

## 🔐 Security Features (Built-in)

✅ **Dependency Scanning** — Detects vulnerable packages
✅ **Secret Scanning** — Prevents accidentally committed credentials
✅ **Code Review Requirement** — No direct push to main
✅ **SAST** — Static analysis for common vulnerabilities
✅ **Signed Commits** — Verify code authenticity

---

## 🎓 This Workshop Covers

**Agenda (45 minutes):**
1. **Developer pain points** — What's slow today? (5 min)
2. **Developer lifecycle walkthrough** — Show how it works (20 min)
3. **Live demo** — Trigger a PR → deploy (10 min)
4. **Value story** — DORA metrics impact (8 min)
5. **Q&A** (2 min)

---

## 🤝 For Your Team

### I'm a developer. How do I use this?
→ Follow [Developer Lifecycle](docs/DEVELOPER_LIFECYCLE.md)

### I'm managing deployments. How does auto-deploy work?
→ See [GitHub Workflow Automation](docs/GHCP_WORKFLOW_AUTOMATION.md)

### I need to understand the security gates.
→ Check [DevSecOps Best Practices](docs/DEVSECOPS_BEST_PRACTICES.md)

### I want to know what metrics we're improving.
→ Read [DORA Metrics Guide](docs/DORA_METRICS_GUIDE.md)

---

## 📝 License

MIT
