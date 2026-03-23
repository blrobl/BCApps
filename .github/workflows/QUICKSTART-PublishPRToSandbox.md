# Quick Start Guide: Publish PR to Sandbox

Get up and running with the Publish PR to Sandbox pipeline in 5 minutes!

## Prerequisites Checklist

- [ ] GitHub repository access with Actions enabled
- [ ] Business Central SaaS Sandbox environment
- [ ] Azure AD tenant access (to create app registration)
- [ ] Admin access to BC Admin Center

## Step-by-Step Setup

### Step 1: Create Azure AD App Registration (5 minutes)

1. Go to [Azure Portal](https://portal.azure.com) → **Azure Active Directory** → **App registrations**

2. Click **"New registration"**
   - Name: `BC-GitHub-Actions`
   - Account types: "Accounts in this organizational directory only"
   - Click **Register**

3. Copy these values (you'll need them later):
   - **Application (client) ID**: `________________________________________`
   - **Directory (tenant) ID**: `________________________________________`

4. Create a **Client Secret**:
   - Go to **Certificates & secrets** → **New client secret**
   - Description: `GitHub Actions`
   - Expires: `6 months` (or your preference)
   - Click **Add**
   - **⚠️ COPY THE SECRET VALUE NOW**: `________________________________________`

5. Configure **API Permissions**:
   - Go to **API permissions** → **Add a permission**
   - Select **APIs my organization uses** → Search for "Dynamics 365 Business Central"
   - Select **Delegated permissions**
   - Check: `Automation.ReadWrite.All` and `user_impersonation`
   - Click **Add permissions**
   - Click **Grant admin consent for [your tenant]**

### Step 2: Create GitHub Secret (2 minutes)

1. Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

2. Click **"New repository secret"**

3. Set the secret:
   - **Name**: `ADMIN_CENTER_API_CREDENTIALS`
   - **Value**: Use this JSON template (fill in your values):
     ```json
     {
       "tenantId": "YOUR_DIRECTORY_TENANT_ID",
       "clientId": "YOUR_APPLICATION_CLIENT_ID",
       "clientSecret": "YOUR_CLIENT_SECRET_VALUE",
       "scopes": "https://api.businesscentral.dynamics.com/.default"
     }
     ```

4. Click **"Add secret"**

### Step 3: Verify Environment Configuration (1 minute)

The pipeline is currently configured for:
- **Tenant ID**: `f0ac72d1-c1b3-4c2a-a196-8fb82cac5934`
- **Environment**: `a47676_p47575_US_29-0-cdsb`
- **Country**: `us`

**If these match your environment**, you're good to go! ✅

**If you need different settings**, edit `.github/workflows/PublishPRToSandbox.yaml`:

```yaml
env:
  TENANT_ID: 'f0ac72d1-c1b3-4c2a-a196-8fb82cac5934'  # ← Change this
  ENVIRONMENT_NAME: 'a47676_p47575_US_29-0-cdsb'      # ← Change this
  COUNTRY: 'us'                                       # ← Change this
```

### Step 4: Run Your First Pipeline (2 minutes)

1. **Find a Pull Request** to test
   - **From microsoft/BCApps**: Find any PR number from the upstream repo
   - **From your fork**: Create or find a PR in your own repository

2. Go to **Actions** tab → **Publish PR to Sandbox Environment**

3. Click **"Run workflow"**

4. Fill in:
   - **PR number**: `123` (the PR number you want to test)
   - **Fetch PR from upstream repo**:
     - ✅ **Checked (default)**: Fetches from microsoft/BCApps (most common use case)
     - ⬜ **Unchecked**: Fetches from your fork repository
   - **New branch name**: (leave empty for default)
   - **Skip branch creation**: (leave unchecked)

5. Click **"Run workflow"**

6. Wait ~2-5 minutes (depending on app size)

7. Check the **workflow summary** for confirmation! 🎉
   - Note: If using upstream repo, a comment won't be posted on the microsoft/BCApps PR (no permission), but you'll see the summary in the workflow run

### Step 5: Use the Configured Environment (1 minute)

1. **Checkout the new branch**:
   ```bash
   git fetch
   git checkout pr-123-sandbox-publish
   ```

2. **Open in VS Code**:
   ```bash
   code "src/System Application"
   # OR
   code "src/Business Foundation"
   ```

3. **Press F5** to start debugging

4. **Sign in** with your Azure AD credentials

5. **Start developing!** 🚀

## Verification Checklist

After your first successful run:

- [ ] Workflow completed successfully (green checkmark in Actions tab)
- [ ] Comment appeared on the PR (only if using fork PRs, not upstream)
- [ ] Workflow summary shows deployment details (in Actions → Run → Summary)
- [ ] New branch was created (e.g., `pr-123-sandbox-publish`)
- [ ] launch.json files exist in `.vscode/` folders
- [ ] Apps appear in BC Admin Center → Environment → Apps
- [ ] Can debug from VS Code using F5

## Common First-Time Issues

### ❌ "Authentication failed"

**Fix**: Double-check your `ADMIN_CENTER_API_CREDENTIALS` secret:
- Verify all three values (tenantId, clientId, clientSecret)
- Ensure no extra spaces or quotes
- Check the client secret hasn't expired
- Verify you clicked "Grant admin consent" for API permissions

### ❌ "Environment not found"

**Fix**: Verify the environment name:
- Go to BC Admin Center
- Copy the exact environment name (case-sensitive)
- Update `ENVIRONMENT_NAME` in the workflow file
- Ensure it's a **Sandbox** (not Production)

### ❌ "Permission denied" when pushing

**Fix**: Check repository permissions:
- Ensure Actions have write permissions: Settings → Actions → General → Workflow permissions → "Read and write permissions"

### ❌ "App failed to compile"

**Fix**: Verify BC version compatibility:
- Check your sandbox BC version matches the app target version (29.0)
- Ensure all dependencies are available in the environment

## What's Next?

Now that you have the pipeline working:

1. **Optimize**: Set up a self-hosted runner for 2-3x faster execution
   - See [SELF-HOSTED-RUNNER-GUIDE.md](./SELF-HOSTED-RUNNER-GUIDE.md)
   - 25 minutes setup time
   - Saves ~2-3 minutes per run

2. **Customize**: Edit the script to publish additional apps

3. **Automate**: Trigger the workflow automatically on PR labels

4. **Extend**: Add testing steps after publishing

5. **Share**: Let your team use the same pipeline!

## Quick Reference

### Run Pipeline
```
Actions → Publish PR to Sandbox Environment → Run workflow
```

### Checkout Configured Branch
```bash
git checkout pr-<NUMBER>-sandbox-publish
```

### Debug from VS Code
```
F5 → Select "Cloud Sandbox (...)" → Sign in → Debug!
```

## Need Help?

- 📖 Full documentation: [README-PublishPRToSandbox.md](./README-PublishPRToSandbox.md)
- 🔧 Troubleshooting: See full README
- 🐛 Issues: Check workflow logs in Actions tab
- 💬 AL-Go Docs: https://github.com/microsoft/AL-Go

## Template for Your Notes

Keep track of your configuration:

```
Environment Configuration
─────────────────────────
Tenant ID:          f0ac72d1-c1b3-4c2a-a196-8fb82cac5934
Environment Name:   a47676_p47575_US_29-0-cdsb
Country:            us

Azure AD App Registration
─────────────────────────
App Name:           BC-GitHub-Actions
Application ID:     ________________________________________
Tenant ID:          ________________________________________
Secret Expiry:      ________________________________________

Last Pipeline Run
─────────────────────────
Date:               ________________________________________
PR Number:          ________________________________________
Branch Created:     ________________________________________
Status:             ________________________________________
```

---

**Ready to publish? Let's go!** 🚀
