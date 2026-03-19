# Publish PR to Sandbox Environment Pipeline

This pipeline allows you to automatically publish changes from a Pull Request to a Business Central SaaS Sandbox environment. It creates a new branch with modified `launch.json` files configured to connect to your sandbox and publishes the System Application and Business Foundation apps.

## Overview

**Workflow File**: `.github/workflows/PublishPRToSandbox.yaml`
**Script**: `.github/scripts/PublishToSandbox.ps1`

### What it does

1. ✅ Takes a PR number as input
2. ✅ Checks out the PR branch
3. ✅ Creates a new branch (optional) with sandbox-specific configuration
4. ✅ Modifies `launch.json` files to connect to your specified BC SaaS sandbox
5. ✅ Publishes **System Application** and **Business Foundation** apps to the sandbox
6. ✅ Commits the changes and posts a summary comment on the PR

## Prerequisites

### 1. GitHub Repository Secret: `ADMIN_CENTER_API_CREDENTIALS`

The pipeline requires authentication to the Business Central Admin Center API. You need to create a secret with credentials.

#### Option A: Interactive Authentication (Device Code Flow)
If you run the script manually, it will prompt you to authenticate via device code flow. This is not suitable for automated pipelines.

#### Option B: Service Principal / App Registration (Recommended for CI/CD)

1. **Create an Azure AD App Registration**:
   - Go to [Azure Portal](https://portal.azure.com) → Azure Active Directory → App registrations
   - Click "New registration"
   - Name: `BC Admin Center API - GitHub Actions`
   - Supported account types: "Accounts in this organizational directory only"
   - Click "Register"

2. **Configure API Permissions**:
   - Go to "API permissions"
   - Click "Add a permission"
   - Select "Dynamics 365 Business Central"
   - Choose "Delegated permissions"
   - Add: `Automation.ReadWrite.All` and `user_impersonation`
   - Click "Grant admin consent"

3. **Create a Client Secret**:
   - Go to "Certificates & secrets"
   - Click "New client secret"
   - Description: `GitHub Actions Secret`
   - Expires: Choose appropriate expiration
   - Click "Add"
   - **Copy the secret value immediately** (you won't be able to see it again)

4. **Get the Application (Client) ID and Tenant ID**:
   - Go to "Overview"
   - Copy the "Application (client) ID"
   - Copy the "Directory (tenant) ID"

5. **Create the GitHub Secret**:
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `ADMIN_CENTER_API_CREDENTIALS`
   - Value (JSON format):
     ```json
     {
       "tenantId": "YOUR_TENANT_ID",
       "clientId": "YOUR_APPLICATION_ID",
       "clientSecret": "YOUR_CLIENT_SECRET",
       "scopes": "https://api.businesscentral.dynamics.com/.default"
     }
     ```
   - Click "Add secret"

#### Option C: Refresh Token (Alternative)

If you have a refresh token for a user with BC Admin Center access:

```json
{
  "tenantId": "YOUR_TENANT_ID",
  "refreshToken": "YOUR_REFRESH_TOKEN"
}
```

### 2. Verify Environment Configuration

The pipeline is currently configured for:
- **Tenant ID**: `f0ac72d1-c1b3-4c2a-a196-8fb82cac5934`
- **Environment Name**: `a47676_p47575_US_29-0-cdsb`
- **Country**: `us`

To change these, edit the `env` section in `.github/workflows/PublishPRToSandbox.yaml`:

```yaml
env:
  TENANT_ID: 'your-tenant-id'
  ENVIRONMENT_NAME: 'your-environment-name'
  COUNTRY: 'us'  # or gb, dk, etc.
```

## Usage

### Running the Workflow

1. **Navigate to Actions tab** in your GitHub repository
2. **Select "Publish PR to Sandbox Environment"** workflow
3. **Click "Run workflow"** button
4. **Fill in the inputs**:
   - **PR number**: The number of the pull request (e.g., `123`)
   - **New branch name** (optional): Custom branch name (defaults to `pr-<number>-sandbox-publish`)
   - **Skip branch creation** (optional): Check this to publish directly from the PR branch without creating a new branch

5. **Click "Run workflow"**

### Example Scenarios

#### Scenario 1: Create a new branch with sandbox configuration
```
PR number: 123
New branch name: (leave empty for default)
Skip branch creation: false
```
**Result**: Creates branch `pr-123-sandbox-publish` with modified launch.json and publishes apps

#### Scenario 2: Use custom branch name
```
PR number: 456
New branch name: feature/test-in-sandbox
Skip branch creation: false
```
**Result**: Creates branch `feature/test-in-sandbox` with configuration

#### Scenario 3: Publish without creating a branch
```
PR number: 789
New branch name: (not applicable)
Skip branch creation: true
```
**Result**: Uses the PR branch directly, only publishes apps (no commit)

## What Gets Modified

### launch.json Configuration

The script creates/updates `.vscode/launch.json` files in:
- `src/System Application/.vscode/launch.json`
- `src/Business Foundation/.vscode/launch.json`

Each launch.json gets a new configuration:

```json
{
  "type": "al",
  "request": "launch",
  "name": "Cloud Sandbox (a47676_p47575_US_29-0-cdsb)",
  "environmentType": "Sandbox",
  "environmentName": "a47676_p47675_US_29-0-cdsb",
  "tenant": "f0ac72d1-c1b3-4c2a-a196-8fb82cac5934",
  "authentication": "AAD",
  "startupObjectType": "Page",
  "startupObjectId": 22,
  "schemaUpdateMode": "Synchronize",
  "breakOnError": true,
  "launchBrowser": true,
  "enableLongRunningSqlStatements": true,
  "enableSqlInformationDebugger": true,
  "dependencyPublishingOption": "Ignore"
}
```

## Using the Configured Environment

After the pipeline completes:

1. **Checkout the branch**:
   ```bash
   git checkout pr-123-sandbox-publish
   ```

2. **Open workspace in VS Code**:
   - Open `src/System Application/SystemApplication.code-workspace` OR
   - Open `src/Business Foundation/BusinessFoundation.code-workspace`

3. **Start debugging**:
   - Press `F5` OR
   - Go to Run and Debug panel
   - Select "Cloud Sandbox (a47676_p47675_US_29-0-cdsb)"
   - Click "Start Debugging"

4. **Authenticate**:
   - VS Code will prompt you to sign in with Azure AD
   - Use credentials that have access to the BC sandbox environment

5. **Develop and test**:
   - Your local changes will be published to the sandbox
   - You can debug AL code in the cloud environment

## Workflow Outputs

The workflow will:

1. **Post a comment on the PR** with:
   - Environment details
   - Published apps list
   - Branch information
   - Instructions for using the configuration

2. **Create a commit** (if not skipping branch creation) with:
   - Modified launch.json files
   - Commit message detailing the configuration

## Troubleshooting

### Authentication Errors

**Error**: "Authentication failed" or "Credentials not found"

**Solution**:
- Ensure `ADMIN_CENTER_API_CREDENTIALS` secret is correctly configured
- Verify the service principal has proper permissions
- Check that the client secret hasn't expired

### Environment Not Found

**Error**: "Environment not found: a47676_p47675_US_29-0-cdsb"

**Solution**:
- Verify the environment name is correct
- Check that the environment exists in your BC Admin Center
- Ensure the environment is a Sandbox (not Production)
- Verify the service principal/user has access to the environment

### App Publishing Fails

**Error**: "Failed to publish app" or dependency errors

**Solution**:
- Ensure the sandbox environment is running (not suspended)
- Check that the BC version in the sandbox matches the app target version
- Verify app dependencies are satisfied in the environment
- Check the AL-Go build completed successfully for the apps

### Permission Denied on Git Push

**Error**: "Permission denied" when pushing to branch

**Solution**:
- Ensure the workflow has `contents: write` permission (already configured)
- Check that branch protection rules aren't preventing the push
- Verify the branch name doesn't conflict with existing protection patterns

## Advanced Configuration

### Publishing Additional Apps

To publish more apps beyond System Application and Business Foundation, modify `.github/scripts/PublishToSandbox.ps1`:

1. Add workspace configuration:
   ```powershell
   $myAppWorkspace = Join-Path $BaseFolder "src\Apps\W1\MyApp"

   New-CloudSandboxLaunchConfig `
       -WorkspacePath $myAppWorkspace `
       -ConfigName "Cloud Sandbox ($EnvironmentName)" `
       -TenantId $TenantId `
       -EnvironmentName $EnvironmentName
   ```

2. Update the AL-Go project path when calling `CreateDevEnv`

### Using Different AL-Go Projects

The script currently uses the "System Application" AL-Go project. To change this:

```powershell
$project = GetProject -baseFolder $alGoBaseFolder -projectALGoFolder (Join-Path $BaseFolder "build\projects\YOUR_PROJECT\.AL-Go")
```

### Customizing Launch Configuration

To customize the launch.json settings, modify the `New-CloudSandboxLaunchConfig` function in the script:

```powershell
$cloudConfig = @{
    "type" = "al"
    "request" = "launch"
    # ... add your custom settings
    "schemaUpdateMode" = "ForceSync"  # Example: change sync mode
    "startupObjectId" = 9305          # Example: different startup page
}
```

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  GitHub Actions Workflow                                    │
│  .github/workflows/PublishPRToSandbox.yaml                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ├─► Get PR Info (GitHub API)
                      │
                      ├─► Checkout PR Branch
                      │
                      ├─► Create New Branch (optional)
                      │
                      ├─► Call PowerShell Script
                      │   │
                      │   └─► .github/scripts/PublishToSandbox.ps1
                      │       │
                      │       ├─► Configure launch.json files
                      │       │   ├─► System Application
                      │       │   └─► Business Foundation
                      │       │
                      │       ├─► Download AL-Go Helpers
                      │       │
                      │       ├─► Call CreateDevEnv (AL-Go)
                      │       │   │
                      │       │   ├─► Authenticate to BC Admin Center
                      │       │   ├─► Build Apps
                      │       │   └─► Publish to Sandbox
                      │       │
                      │       └─► Return Success/Failure
                      │
                      ├─► Commit launch.json changes
                      │
                      ├─► Push to branch
                      │
                      └─► Post PR comment
```

## Security Considerations

1. **Secrets Protection**: Never commit `ADMIN_CENTER_API_CREDENTIALS` to the repository
2. **Least Privilege**: Use a service principal with minimum required permissions
3. **Secret Rotation**: Regularly rotate client secrets and refresh tokens
4. **Audit Logs**: Monitor Azure AD sign-in logs for service principal activity
5. **Branch Protection**: Consider requiring reviews before running this workflow on sensitive PRs

## Support

For issues or questions:
- Check the workflow run logs in the Actions tab
- Review the AL-Go documentation: https://github.com/microsoft/AL-Go
- BC Admin Center API: https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/administration-center-api

## Related Documentation

- [AL-Go for GitHub](https://github.com/microsoft/AL-Go)
- [BC Admin Center API](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/administration-center-api)
- [Cloud Dev Environment Setup](https://github.com/microsoft/AL-Go/blob/main/Scenarios/CreateOnlineDevEnv2.md)
- [AL-Go Settings](https://aka.ms/algosettings)
