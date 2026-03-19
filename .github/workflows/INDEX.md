# Publish PR to Sandbox - Documentation Index

Welcome! This index helps you find the right documentation for your needs.

## 📚 Quick Navigation

### 🚀 I want to get started NOW!
→ **[QUICKSTART-PublishPRToSandbox.md](./QUICKSTART-PublishPRToSandbox.md)**

Start here for a 5-minute setup guide with step-by-step instructions.

---

### 📖 I need detailed documentation
→ **[README-PublishPRToSandbox.md](./README-PublishPRToSandbox.md)**

Complete reference guide with troubleshooting, advanced configuration, and architecture details.

---

### 🎯 I want an overview first
→ **[PIPELINE-SUMMARY.md](./PIPELINE-SUMMARY.md)**

High-level summary of what the pipeline does, how it works, and what was created.

---

### 🔧 I need to configure secrets
→ **[credentials-template.json](./credentials-template.json)**

Template file for creating the `ADMIN_CENTER_API_CREDENTIALS` GitHub secret.

---

### 💻 I want to see the code
→ **[PublishPRToSandbox.yaml](./PublishPRToSandbox.yaml)** - GitHub Actions workflow
→ **[../scripts/PublishToSandbox.ps1](../scripts/PublishToSandbox.ps1)** - PowerShell script

---

## 📋 Documentation Matrix

| I want to... | Read this document | Est. Time |
|-------------|-------------------|-----------|
| Set up the pipeline for the first time | QUICKSTART | 5 min |
| Understand what the pipeline does | PIPELINE-SUMMARY | 3 min |
| Run the pipeline | QUICKSTART → "Step 4" | 2 min |
| Configure Azure AD app | QUICKSTART → "Step 1" | 5 min |
| Set up GitHub secret | QUICKSTART → "Step 2" | 2 min |
| Troubleshoot authentication issues | README → "Troubleshooting" | 5 min |
| Customize which apps are published | README → "Advanced Configuration" | 10 min |
| Change environment settings | README → "Prerequisites → 2" | 2 min |
| Understand the architecture | README → "Pipeline Architecture" | 5 min |
| Extend the pipeline | README → "Advanced Configuration" | 15 min |
| Create the credentials JSON | credentials-template.json | 2 min |

## 🗂️ File Structure

```
.github/
├── workflows/
│   ├── PublishPRToSandbox.yaml          ← Main workflow file
│   ├── INDEX.md                         ← You are here!
│   ├── QUICKSTART-PublishPRToSandbox.md ← Start here
│   ├── README-PublishPRToSandbox.md     ← Full documentation
│   ├── PIPELINE-SUMMARY.md              ← Overview
│   └── credentials-template.json        ← Secret template
└── scripts/
    └── PublishToSandbox.ps1              ← Main script
```

## 🎓 Learning Path

### Beginner Path
1. Read **PIPELINE-SUMMARY** (understand what it does)
2. Follow **QUICKSTART** (set it up)
3. Run your first pipeline
4. Bookmark **README** for troubleshooting

### Advanced Path
1. Skim **PIPELINE-SUMMARY**
2. Read **README** → "Advanced Configuration"
3. Modify **PublishToSandbox.ps1** for your needs
4. Update **PublishPRToSandbox.yaml** workflow

### Troubleshooting Path
1. Check **README** → "Troubleshooting" section
2. Review workflow logs in GitHub Actions
3. Verify credentials using **credentials-template.json**
4. Check **QUICKSTART** → "Common First-Time Issues"

## 🔑 Key Concepts

### What is this pipeline?
An automated GitHub Actions workflow that:
- Takes a Pull Request
- Creates a new branch with sandbox configuration
- Publishes Business Central apps to your SaaS sandbox
- Configures VS Code for cloud debugging

### What do I need?
- BC SaaS Sandbox environment
- Azure AD app registration (service principal)
- GitHub secret with credentials
- 10 minutes for initial setup

### What does it create?
- A new branch with modified launch.json files
- Published apps in your BC sandbox
- PR comment with status and instructions
- Ready-to-use VS Code debugging configuration

## ⚡ Quick Reference Card

```
┌─────────────────────────────────────────────────────┐
│  PUBLISH PR TO SANDBOX - QUICK REFERENCE            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  TO RUN:                                           │
│    GitHub → Actions → Publish PR to Sandbox        │
│    → Run workflow → Enter PR number → Run          │
│                                                     │
│  CURRENT ENVIRONMENT:                              │
│    Tenant:  f0ac72d1-c1b3-4c2a-a196-8fb82cac5934  │
│    Env:     a47676_p47575_US_29-0-cdsb            │
│    Country: us                                     │
│                                                     │
│  REQUIRED SECRET:                                  │
│    Name:  ADMIN_CENTER_API_CREDENTIALS            │
│    Type:  JSON with tenantId, clientId, secret    │
│                                                     │
│  APPS PUBLISHED:                                   │
│    • System Application                           │
│    • Business Foundation                          │
│                                                     │
│  OUTPUT:                                           │
│    • Branch: pr-{number}-sandbox-publish          │
│    • Files: .vscode/launch.json (configured)      │
│    • Comment: Posted on PR with details           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## 📞 Getting Help

### In this order:

1. **Check the relevant documentation**
   - Use the table above to find the right doc

2. **Review workflow logs**
   - GitHub → Actions → Your workflow run → Logs

3. **Verify prerequisites**
   - QUICKSTART → "Prerequisites Checklist"

4. **Check common issues**
   - QUICKSTART → "Common First-Time Issues"
   - README → "Troubleshooting"

5. **Review external resources**
   - AL-Go: https://github.com/microsoft/AL-Go
   - BC Admin API: https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/administration-center-api

## ✅ Checklist for First-Time Setup

Use this checklist to track your progress:

- [ ] Read PIPELINE-SUMMARY for overview
- [ ] Create Azure AD app registration
- [ ] Configure API permissions
- [ ] Create client secret
- [ ] Add GitHub secret `ADMIN_CENTER_API_CREDENTIALS`
- [ ] Verify environment configuration in workflow
- [ ] Run test pipeline on a PR
- [ ] Verify branch was created
- [ ] Verify apps were published in BC Admin Center
- [ ] Test F5 debugging from VS Code
- [ ] Share setup with team

## 🎯 Common Tasks

| Task | Command/Location |
|------|-----------------|
| Run pipeline | Actions → Publish PR to Sandbox → Run workflow |
| View pipeline history | Actions → Publish PR to Sandbox |
| Update environment | Edit `.github/workflows/PublishPRToSandbox.yaml` |
| Modify published apps | Edit `.github/scripts/PublishToSandbox.ps1` |
| Update secret | Settings → Secrets → ADMIN_CENTER_API_CREDENTIALS |
| Check app status | BC Admin Center → Environment → Apps |
| View workflow logs | Actions → [Run] → View logs |

## 📊 Documentation Status

| Document | Status | Last Updated | Completeness |
|----------|--------|--------------|--------------|
| INDEX.md | ✅ Current | 2026-03-19 | 100% |
| QUICKSTART | ✅ Current | 2026-03-19 | 100% |
| README | ✅ Current | 2026-03-19 | 100% |
| PIPELINE-SUMMARY | ✅ Current | 2026-03-19 | 100% |
| credentials-template | ✅ Current | 2026-03-19 | 100% |
| Workflow YAML | ✅ Current | 2026-03-19 | 100% |
| PowerShell Script | ✅ Current | 2026-03-19 | 100% |

## 🚀 Ready to Start?

→ **[Go to Quick Start Guide](./QUICKSTART-PublishPRToSandbox.md)**

---

*Happy Publishing! 🎉*
