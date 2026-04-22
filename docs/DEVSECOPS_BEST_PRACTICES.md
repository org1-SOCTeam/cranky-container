# DevSecOps Best Practices

This guide covers the security patterns built into the Cranky Container workflow.

---

## 🔐 Security Gates in This Workflow

### 1. **Dependency Scanning**
*Detects vulnerable packages before they reach production.*

**What it does:**
- Scans `requirements.txt` for known vulnerabilities
- Checks against CVE database (Common Vulnerabilities & Exposures)
- Warns on outdated packages

**Trigger:** Every push to main/develop

**Example:**
```bash
pip install safety
safety check

# Output:
# [32m+==============================================================================+
# |                      /$$$$$$            /$$                /$$
# |                     /$$__  $$          | $$               | $$
# |   /$$$$$$$  /$$$$$$| $$  \__//$$$$$$  /$$$$$$   /$$$$$$  /$$$$$$
# |  /$$_____/ |____  /| $$$$   /$$__  $$|_  $$_/  /$$__  $$|_  $$_/
# | |  $$$$$$   /$$$$$$$| $$_/  | $$  \ $$  | $$   | $$$$$$$$  | $$
# |  \____  $$ /$$__  $$| $$    | $$  | $$  | $$ /$$| $$_____/  | $$ /$$
# |  /$$$$$$$/|  $$$$$$$| $$    |  $$$$$$/  |  $$$$/|  $$$$$$$  |  $$$$/
# | |_______/  \_______/|__/     \______/    \___/  \_______/   \___/
# |
# | Safety 2.3.5
# +==============================================================================+
# Scanning for known security vulnerabilities...
#
# ✓ All packages are safe
```

**If vulnerabilities found:**
```
❌ 3 vulnerabilities found
• fastapi 0.95.0 has known XSS issue
• cryptography < 41.0.0 has padding oracle vulnerability
• requests < 2.28.0 has proxy auth bypass

Action: Update packages before deployment
```

---

### 2. **SAST — Static Application Security Testing**
*Analyzes code without running it to find security issues.*

**What it detects:**
- SQL injection vulnerabilities
- Hardcoded credentials / secrets
- Insecure cryptography usage
- Command injection risks
- Path traversal vulnerabilities

**Tools used:**
- **Bandit** — Python-specific security linter
- **Semgrep** — Pattern-based code analysis

**Example:**

```python
# ❌ BAD: Hardcoded password
db_password = "secret123"
conn = connect(password=db_password)

# ❌ BAD: SQL injection risk
query = f"SELECT * FROM users WHERE id = {user_id}"
db.execute(query)

# ✅ GOOD: Use environment variables
db_password = os.getenv("DB_PASSWORD")

# ✅ GOOD: Use parameterized queries
query = "SELECT * FROM users WHERE id = ?"
db.execute(query, (user_id,))
```

**Workflow catches these and blocks merge if critical.**

---

### 3. **Secret Scanning**
*Prevents accidentally committing passwords, API keys, tokens.*

**What it detects:**
- Private SSH keys
- AWS access keys
- GitHub personal access tokens
- Database passwords
- API keys in code

**How it works:**
1. Before pushing, scan your local files:
```bash
# Install detect-secrets
pip install detect-secrets

# Scan your code
detect-secrets scan

# Output:
# {
#   "version": "1.1.0",
#   "plugins_used": [...],
#   "results": {
#     "src/config.py": [
#       {
#         "type": "Basic Auth Credentials",
#         "line_number": 45
#       }
#     ]
#   }
# }
```

2. If you accidentally commit, GitHub's secret scanning catches it:
```
⚠️  GitHub Secret Scanning Alert

Found: GitHub Personal Access Token in commit abc123

Action: Token has been revoked automatically
GitHub has notified the token owner
Review your recent commits
```

**Prevention:**
```bash
# ❌ Never commit
AWS_KEY=AKIAIOSFODNN7EXAMPLE
API_TOKEN=ghp_1234567890abcdef

# ✅ Use environment variables
export AWS_KEY=...  # Set locally
# Reference in code:
api_key = os.getenv("API_TOKEN")

# ✅ Use .env file (in .gitignore)
# .env (never committed)
API_TOKEN=secret123

# .env.example (committed, for template)
API_TOKEN=your-token-here
```

---

### 4. **Code Review Requirement**
*Human review catches logic errors that automation misses.*

**Requirements:**
- At least 1 approved review needed before merge
- Reviewer must be a different person than author
- Dismisses previous approvals if author pushes new commits

**What reviewers should check:**
- ✅ Logic correctness (does it do what it claims?)
- ✅ Security assumptions (is error handling correct?)
- ✅ Edge cases (what if input is empty, null, huge?)
- ✅ No secrets committed
- ✅ Tests cover the changes

**Example review comment:**
```
📝 Review: Requested Changes

Line 42: The SQL query should use parameterized queries to prevent injection.
Could you update to use prepared statements?

Line 58: What happens if the API is down? Should we add a timeout?

Line 75: This endpoint doesn't check user permissions. Is that intentional?
```

---

### 5. **Container Image Scanning**
*Checks Docker images for vulnerable dependencies.*

**Tools:**
- **Trivy** — Scans container images for CVEs
- **Docker Scout** — GitHub integration for container scanning

**Example:**
```bash
trivy image cranky-container:latest

# Output:
# cranky-container:latest (debian 12.1)
#
# Total: 3 (CRITICAL: 0, HIGH: 2, MEDIUM: 1)
#
# python3.11 (deb)
# ├─ CVE-2023-29491  [HIGH]
# └─ python is vulnerable to XXE attack
#    └─ Introduced by: python3.11 3.11.5
#        └─ Fixed by: 3.11.6
#
# libssl3 (deb)
# └─ CVE-2023-2650  [HIGH]
#    └─ OpenSSL has memory corruption bug
```

---

## 🛡️ Branch Protection Rules

**What's enforced:**

```
Main branch: master/main

Rules:
□ Require pull request reviews before merging
  └─ Required number of reviews: 1
  └─ Dismiss stale pull request approvals

□ Require status checks to pass before merging
  └─ Tests (CI workflow)
  └─ Security scan
  └─ Container build

□ Require branches to be up to date before merging
  └─ Prevents merging if someone pushed to main

□ Require code owners review for changes to specified files
  └─ CODEOWNERS file defines who reviews what

□ Require signed commits
  └─ Only verified commits can merge
```

**Bypass:**
- Only repository admins can bypass
- Creates audit log
- Should be rare/emergency only

---

## 🚨 How to Respond to Security Issues

### If a secret is committed (accidental)

**Immediately:**
1. Rotate/revoke the secret (e.g., regenerate API key)
2. Force-push to remove from history (⚠️ only for main, requires bypass)
   ```bash
   git reset HEAD~1  # Undo the commit
   git push --force-with-lease origin main
   ```
3. Add to `.gitignore` + update code to use environment variable

**Or (safer for teams):**
1. Create a revert PR (doesn't remove history but prevents exposure)
   ```bash
   git revert HEAD
   git push origin feature/revert-secret-commit
   ```
2. Rotate the secret
3. Audit logs to see who accessed it

### If vulnerability is found in dependency

**Triage:**
1. Check if it affects your code
   - Is the vulnerable function used?
   - Can it be triggered by user input?
2. If critical: Deploy a fix immediately
   ```bash
   # Update dependencies
   pip install --upgrade {package}
   git commit -m "security: patch CVE-XXXX"
   git push
   # Auto-deploy
   ```
3. If low: Schedule for next release

### If code review finds security issue

**Example: Hardcoded secret**
```
Reviewer comment:
"I see the API key is hardcoded here (line 42).
This should come from an environment variable instead.

Also, who has access to this secret? Can we rotate it?"
```

**Developer fixes:**
```python
# Before
API_KEY = "sk_live_1234567890abcdef"
headers = {"Authorization": f"Bearer {API_KEY}"}

# After
API_KEY = os.getenv("STRIPE_API_KEY")
if not API_KEY:
    raise ValueError("STRIPE_API_KEY environment variable not set")
headers = {"Authorization": f"Bearer {API_KEY}"}
```

---

## 📋 Pre-Commit Checklist

Before pushing code:

- [ ] No secrets in code (`detect-secrets scan`)
- [ ] Tests pass locally (`pytest`)
- [ ] Linting passes (`pylint`, `black`)
- [ ] No hardcoded credentials
- [ ] Dependencies are up-to-date (`pip list --outdated`)
- [ ] New dependencies added to `requirements.txt`
- [ ] Sensitive operations use environment variables
- [ ] Error messages don't leak information
- [ ] Input validation is in place
- [ ] Dependencies have no known vulnerabilities

---

## 🔗 Related Documentation

- [Developer Lifecycle](DEVELOPER_LIFECYCLE.md)
- [DORA Metrics](DORA_METRICS_GUIDE.md)
- [GitHub Workflow Automation](GHCP_WORKFLOW_AUTOMATION.md)

---

## 📚 Resources

- **OWASP Top 10:** https://owasp.org/Top10
- **Safety (Python vulnerability db):** https://github.com/pyupio/safety
- **Bandit (Python security):** https://bandit.readthedocs.io
- **GitHub Secret Scanning:** https://docs.github.com/en/code-security/secret-scanning

---

**Remember: Security is everyone's responsibility. Every developer is a security engineer.**
