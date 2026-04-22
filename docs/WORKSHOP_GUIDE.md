# Workshop Guide: GHE DevSecOps Demo (45 min)

## 📋 Overview

**Audience:** CAP development team (manual AWS/Azure deployments)
**Goal:** Show how GitHub Enterprise + CI/CD automates their workflow
**Format:** 45 minutes (presentation + live demo + hands-on)

---

## ⏱️ Agenda Breakdown

| Time | Section | Minutes | Format |
|------|---------|---------|--------|
| 0:00 – 0:05 | **Icebreaker** | 5 | Discussion |
| 0:05 – 0:25 | **Developer Workflow** | 20 | Walk-through + live demo |
| 0:25 – 0:35 | **Value Story (DORA)** | 10 | Slides + metrics |
| 0:35 – 0:42 | **Hands-On Lab** | 7 | Try it themselves |
| 0:42 – 0:45 | **Q&A** | 3 | Open discussion |

---

## 🎬 SECTION 1: Icebreaker (0:00 – 0:05)

### Talking Points

**"Good morning everyone! Thanks for being here. Before we dive in, I want to understand where you're at."**

**Ask the room (engage them):**
1. "How many of you have deployed code to production manually?" 
   - *Listen for hands up. Acknowledgement.*
2. "What's the biggest pain point? Is it testing? Waiting for approvals? Deployment risk?"
   - *Get 2–3 responses. Write them on whiteboard/sticky notes.*
3. "How long does a typical deployment take you? Start to finish?"
   - *Listen: probably 2 weeks, 3 days, etc.*

**Acknowledge their reality:**

"Okay, so you're deploying every 2 weeks, manual testing, 1–2 ops people managing every step. That's actually **the way most enterprises work today**. And it's **not your fault** — that's how systems were designed."

**Transition:**

"What if I told you that you could deploy 10 times a day, have every deployment tested automatically, and get feedback in 15 minutes instead of 2 weeks? That's what we're going to show you today."

---

## 🏗️ SECTION 2: Developer Workflow (0:05 – 0:25)

### Part A: Walk-through (Explain the flow)

**"Let's walk through what the flow looks like."**

**Show diagram / draw on board:**

```
Developer writes code
        ↓
    git push
        ↓
    GitHub detects push
        ↓
    Automated tests run (✅ pass/❌ fail)
    Dependency scan (for security vulnerabilities)
    Code linting (style check)
        ↓
    PR created → awaiting review
        ↓
    Colleague reviews & approves
        ↓
    Merge button → code goes to main
        ↓
    Auto-deploy to Azure
        ↓
    ✅ Live in production (5 minutes later)
```

**Talk through each step (keep it simple):**

**Step 1: Push code**
- "You write code locally, test it, then push to GitHub."
- "Unlike before where you email it or manually upload it."

**Step 2: Automated gates run**
- "The moment you push, tests run automatically."
- "It's like having a QA person who never sleeps, checking every change."
- "If tests fail, you get immediate feedback. You fix it, push again, tests re-run."

**Step 3: Code review**
- "Your colleague gets a notification to review."
- "They look at your code, suggest improvements, approve or ask for changes."
- "This is where knowledge-sharing happens. You're not gatekeeping, you're collaborating."

**Step 4: Merge & Deploy**
- "Once approved, you click merge."
- "GitHub automatically deploys to Azure (no ops person involved)."
- "5 minutes later, your code is live."

**Key benefit:**
- "Everything is automated. No hand-offs. No waiting."

---

### Part B: Live Demo (Show the actual repo)

**Setup before workshop:**
- Have the repo open in a browser (GitHub)
- Have VS Code open locally
- Be ready to push a change

**Live demo script:**

**"Let me show you this in action. I have this cranky-container repo here."**

**[Open GitHub repo in browser]**

```
Show them:
- The main branch (code is here)
- The workflows section (.github/workflows)
  → ci.yml (tests + lint)
  → security-scan.yml (dependency check)
  → deploy-azure.yml (auto-deploy)
- A recent PR as example
  → Show automated checks running
  → Show code review comments
  → Show deployment status
```

**"This is the workflow in action. Let me show you a real example by making a change."**

**[Open VS Code with repo]**

```bash
git checkout -b feature/demo-change
nano src/main.py  # Add a comment or simple change
git add .
git commit -m "feat: add demo feature"
git push origin feature/demo-change
```

**"Watch what happens on GitHub..."**

**[Refresh GitHub]**

- PR auto-created
- Checks start running (show the spinner)
- "Tests are running right now..."
- "In about 2 minutes, you'll see if it passes or fails"

**"This is what your team would do. No deployment team involved, no manual testing, no 2-week wait."**

---

## 💰 SECTION 3: Value Story — DORA Metrics (0:25 – 0:35)

### Talking Points

**"Okay, so you can deploy fast. But why does it matter? Let's talk numbers."**

**Introduce DORA metrics:**

"Google published research on deployment performance. They call it **DORA metrics**. Four things matter:
1. **How often can you deploy?**
2. **How long until code reaches users?**
3. **How fast can you fix a critical bug?**
4. **How many deployments break production?**"

**Show comparison table:**

| Metric | Before (You Today) | After (With GHE) |
|--------|-------------------|------------------|
| Deploy Frequency | 1x per month | 5x per week |
| Lead Time | 14 days | 1 hour |
| MTTR (bug fix) | 3 days | 20 minutes |
| Failure Rate | 40% | 10% |

**Tell a story (make it relatable):**

**"Imagine a customer finds a critical bug at 3 PM on a Friday."**

**Before:**
- "You find the bug, write the fix."
- "But deployment slot isn't until Monday."
- "Customer is broken all weekend."
- "Monday comes, you deploy, it works."
- "Total downtime: 65 hours"

**After:**
- "You find the bug, write the fix (10 min)."
- "Push to GitHub, tests pass (2 min)."
- "Colleague approves (1 min)."
- "Merge, deploy starts (1 min)."
- "5 minutes later, it's live."
- "Total downtime: 20 minutes"
- "You save 65 hours."

**"That's the power. It's not just speed — it's reliability, customer trust, and team sanity."**

---

### Real Metrics from This Repo

**Show GitHub Actions logs** (if you have them):

```
"Here are actual deployment times from our test runs:
- Deployment frequency: 5 runs today (9:00, 10:30, 11:45, 12:10, 13:50)
- Lead time: Average 28 minutes (commit to deployed)
- Failure rate: 0% (all tests passed before deploy)

That's Elite tier performance."
```

---

## 🔧 SECTION 4: Hands-On Lab (0:35 – 0:42)

### Option A: Guided (If audience is less technical)

**"Let's try it. I'm going to guide you step-by-step."**

**Task (pick 1):**

1. **"Update the README"**
   - Clone the repo locally
   - Edit README.md
   - Commit + push
   - Open PR on GitHub
   - Watch tests run

2. **"Add a simple feature"**
   - Create a branch
   - Add a simple Python function (or code snippet)
   - Commit + push
   - Watch GitHub detect it

**Steps:**
```bash
# Step 1: Clone (if you don't have it)
git clone https://github.com/<org>/cranky-container.git
cd cranky-container

# Step 2: Create branch
git checkout -b feature/my-change

# Step 3: Edit file (any file)
# Use your editor to change something
nano README.md
# Add a line like: "# Deployed by: YOUR_NAME"

# Step 4: Commit + push
git add .
git commit -m "feat: add my change"
git push origin feature/my-change

# Step 5: Go to GitHub and see the PR
# Click the link in terminal
```

**"Everyone done? Now go to GitHub. You'll see a PR created automatically. Watch the checks run."**

**"This is what your team does every day."**

---

### Option B: Show-and-Tell (If time is tight)

**"Instead of everyone doing it, I'll show you one more time on screen while you watch. Pay attention to the flow."**

**Live walk-through:**
- Make a change
- Push
- Show PR auto-created
- Show checks running
- Show approval + merge
- Show deploy workflow triggered

---

## ❓ SECTION 5: Q&A (0:42 – 0:45)

### Anticipated Questions & Answers

**Q: "What if I make a mistake and merge bad code?"**
A: "Great question. Two things: First, tests catch most errors automatically. Second, if something gets through, you can revert with 1-click (revert PR). The benefit of deploying fast is you can also fix fast."

**Q: "Who has access to production?"**
A: "Only the auto-deploy workflow. Individual ops people can't manually SSH in and change things. Everything goes through GitHub, so we have an audit trail."

**Q: "What about rollback if something breaks?"**
A: "Create a revert PR (1 click), which undoes the change, deploys the previous version. Usually 2–3 minutes."

**Q: "Do I still need ops?"**
A: "Yes, but differently. Instead of doing repetitive deploys, they focus on infrastructure, monitoring, security hardening."

**Q: "Can I skip code review?"**
A: "No, it's mandatory. This is non-negotiable for security + knowledge-sharing."

**Q: "What if the security scan finds something?"**
A: "The scan warns, but won't block. You review the warning with your team, decide if it's real or not. If it's real, fix it."

---

## 🛠️ Technical Notes (For You)

### Before the Workshop

- [ ] Test all workflows locally
- [ ] Ensure the sample app builds/runs
- [ ] Open a test PR and confirm:
  - [ ] Tests run automatically
  - [ ] Security scan works
  - [ ] Merge works
- [ ] Have Azure deployment ready (or at least the logs showing it works)
- [ ] Have screenshots as backup (in case live demo fails)

### During the Workshop

- [ ] Start with the icebreaker questions (engagement)
- [ ] Walk-through before live demo (set context)
- [ ] Live demo: be okay with it taking longer (people are learning)
- [ ] If live demo breaks: pivot to screenshots/video (have as backup)
- [ ] Hands-on: let people try, don't rush
- [ ] Leave time for Q&A (they will have questions)

### Backup Plan (If demo fails)

- [ ] Have screenshots of:
  - PR with tests running
  - Merge + deploy triggered
  - Deployment success
  - GitHub Actions logs
- [ ] Have a pre-recorded 2-min video of the full flow
- [ ] Have talking points memorized (don't rely on live demo)

---

## 📊 Slide Deck Structure (If Using Slides)

1. **Title slide** — "GitHub Enterprise for Oldschool Dev Teams"
2. **Current pain** — Manual deployment horror story
3. **The workflow** — 7-step flow diagram
4. **Automated gates** — What runs automatically
5. **Code review** — Why it matters
6. **DORA metrics** — The numbers
7. **Before/after timeline** — 2-week vs. 20-min deployment
8. **Security gates** — What's covered
9. **Demo time** — Show it live
10. **Hands-on** — Try it yourselves
11. **Q&A**

---

## 🎓 What They Should Take Away

After 45 minutes, every developer should understand:

✅ **What:** GitHub Enterprise workflow automates deployment
✅ **Why:** Faster feedback, safer deployments, happier teams
✅ **How:** Code → PR → Review → Merge → Auto-Deploy
✅ **Impact:** DORA metrics (deploy 10x faster, fix bugs in 20 min)
✅ **Next:** "Go try it in your own team's repo"

---

## 📝 Post-Workshop Follow-up

**Email them after:**

```
Subject: Thanks for attending! Here's the next step.

Hi everyone,

Thanks for joining the workshop. Here are the resources:

1. This demo repo: [link to cranky-container]
2. Step-by-step guide: [docs/DEVELOPER_LIFECYCLE.md]
3. DORA metrics explainer: [docs/DORA_METRICS_GUIDE.md]
4. GitHub branch protection setup: [docs/GHE_SETUP.md]

Next steps for your team:
- Set up branch protection on your main branch
- Create a test workflow (copy our ci.yml)
- Try deploying a non-critical feature using the flow
- Measure your DORA metrics in 3 months

Questions? Slack me.

Thanks,
[Your name]
```

---

## 🔗 Useful Links (For During Workshop)

- **Demo repo:** `https://github.com/<org>/cranky-container`
- **DORA research:** `https://dora.dev`
- **GitHub Actions docs:** `https://docs.github.com/en/actions`
- **Branch protection:** `https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches`

---

## ✨ Tips for Success

1. **Start with their pain** — Ask about their manual deployment process. They'll relate.
2. **Show, don't tell** — Live demo > slides. Make it real.
3. **Hands-on is key** — Let them push code. Muscle memory.
4. **Celebrate small wins** — When tests pass, cheer. When deploy works, celebrate.
5. **Give them hope** — "You can do this. It's easier than you think."
6. **Leave them with resources** — Links + docs so they don't forget.

---

**Good luck with the workshop! You've got this. 🚀**
