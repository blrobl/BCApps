# Self-Hosted Runner Setup Guide

This guide explains how to set up and use a self-hosted GitHub Actions runner for the **Publish PR to Sandbox** pipeline.

## Why Use a Self-Hosted Runner?

### ✅ Benefits

1. **Faster Execution**
   - Pre-installed dependencies (no download time)
   - Cached PowerShell modules (BCContainerHelper, AL-Go helpers)
   - Local artifact cache
   - No cold start delays

2. **Cost Savings**
   - No GitHub Actions minutes consumption
   - Run unlimited pipelines
   - Better for frequent usage

3. **Better Performance**
   - More powerful hardware than standard GitHub runners
   - Persistent state between runs
   - Dedicated resources

4. **Customization**
   - Pre-configured environment
   - Custom tools and utilities
   - Specific PowerShell versions
   - Network access to internal resources

### ⚠️ Considerations

1. **Maintenance**
   - You manage the runner infrastructure
   - Need to keep runner software updated
   - Security and patching responsibility

2. **Security**
   - Ensure proper isolation if running on shared machines
   - Review code before running on self-hosted runners
   - Use dedicated runner for sensitive operations

3. **Availability**
   - Runner must be online when workflow runs
   - Need to handle restarts and maintenance

## Quick Start

### Option 1: Windows Machine (Recommended)

#### Prerequisites
- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or later
- Administrator access
- Stable internet connection
- At least 8GB RAM, 50GB free disk space

#### Step 1: Set Up the Runner (10 minutes)

1. **Go to GitHub Repository Settings**
   - Navigate to your fork: `https://github.com/YOUR_USERNAME/BCApps`
   - Go to **Settings** → **Actions** → **Runners**
   - Click **"New self-hosted runner"**

2. **Select Windows**
   - Operating System: **Windows**
   - Architecture: **x64**

3. **Download and Configure** (follow GitHub's instructions)
   ```powershell
   # Create a folder
   mkdir C:\actions-runner
   cd C:\actions-runner

   # Download the latest runner package
   Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.XXX.X/actions-runner-win-x64-2.XXX.X.zip -OutFile actions-runner-win-x64-2.XXX.X.zip

   # Extract
   Add-Type -AssemblyName System.IO.Compression.FileSystem
   [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.XXX.X.zip", "$PWD")

   # Configure
   .\config.cmd --url https://github.com/YOUR_USERNAME/BCApps --token YOUR_TOKEN

   # When prompted:
   # - Runner name: bcapps-runner-1 (or your choice)
   # - Labels: self-hosted,Windows,X64 (accept defaults)
   # - Work folder: _work (accept default)
   ```

4. **Install as Windows Service** (runs automatically)
   ```powershell
   # Run as Administrator
   .\svc.sh install
   .\svc.sh start
   ```

   **Or run interactively** (for testing):
   ```powershell
   .\run.cmd
   ```

#### Step 2: Install Dependencies (15 minutes)

Run this PowerShell script as **Administrator** on your runner machine:

```powershell
# Install PowerShell modules
Write-Host "Installing PowerShell modules..." -ForegroundColor Yellow

# Install BcContainerHelper (required for BC operations)
Install-Module -Name BcContainerHelper -Force -AllowClobber
Write-Host "✓ BcContainerHelper installed" -ForegroundColor Green

# Install Git (if not already installed)
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget
    Write-Host "✓ Git installed" -ForegroundColor Green
} else {
    Write-Host "✓ Git already installed" -ForegroundColor Green
}

# Verify installations
Write-Host ""
Write-Host "Verifying installations..." -ForegroundColor Yellow
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "Git Version: $(git --version)" -ForegroundColor Gray
Write-Host "BcContainerHelper Version: $((Get-Module BcContainerHelper -ListAvailable).Version)" -ForegroundColor Gray

Write-Host ""
Write-Host "✓ Self-hosted runner is ready!" -ForegroundColor Green
```

#### Step 3: Verify Runner Status

1. Go to **Settings** → **Actions** → **Runners**
2. You should see your runner with status: **Idle** (green)
3. If offline (red), check the service: `Get-Service actions.runner.*`

### Option 2: Linux Machine (Alternative)

#### Prerequisites
- Ubuntu 20.04+ or similar
- PowerShell Core 7.0+
- sudo access
- At least 8GB RAM, 50GB free disk space

#### Installation

```bash
# Create runner directory
mkdir ~/actions-runner && cd ~/actions-runner

# Download latest runner
curl -o actions-runner-linux-x64-2.XXX.X.tar.gz -L https://github.com/actions/runner/releases/download/v2.XXX.X/actions-runner-linux-x64-2.XXX.X.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.XXX.X.tar.gz

# Configure
./config.sh --url https://github.com/YOUR_USERNAME/BCApps --token YOUR_TOKEN

# Install as service
sudo ./svc.sh install
sudo ./svc.sh start

# Install PowerShell Core
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# Install BcContainerHelper
pwsh -Command "Install-Module -Name BcContainerHelper -Force -AllowClobber"
```

**Note**: Linux runners work but may have limitations with some BC-specific operations.

## Using the Self-Hosted Runner

### Running the Workflow

1. Go to **Actions** → **Publish PR to Sandbox Environment**
2. Click **"Run workflow"**
3. Fill in inputs:
   - **PR number**: Your PR number
   - **Fetch PR from upstream repo**: ✅ (default)
   - **Use self-hosted runner**: ✅ **CHECK THIS BOX**
   - Other inputs as needed
4. Click **"Run workflow"**

### Performance Comparison

| Metric | GitHub-Hosted | Self-Hosted (Optimized) |
|--------|---------------|-------------------------|
| **Runner startup** | ~20-30 seconds | ~5 seconds |
| **Dependency download** | ~60-120 seconds | 0 seconds (cached) |
| **AL-Go helpers** | ~30 seconds | ~5 seconds (cached) |
| **Total overhead** | ~2-3 minutes | ~10-20 seconds |
| **Overall speedup** | Baseline | **2-3x faster** |

## Advanced Configuration

### Pre-Install AL-Go Helpers

To speed up subsequent runs, pre-download AL-Go helper files:

```powershell
# Create cache directory
$cacheDir = "C:\actions-runner\cache\al-go-helpers"
New-Item -Path $cacheDir -ItemType Directory -Force

# Download AL-Go helpers
$alGoVersion = "91c2f1bab7959cffc66fd9513a1d83ec9f641e30"
$baseUrl = "https://raw.githubusercontent.com/microsoft/AL-Go/$alGoVersion/Actions"

$files = @(
    "Github-Helper.psm1",
    ".Modules/ReadSettings.psm1",
    ".Modules/DebugLogHelper.psm1",
    "AL-Go-Helper.ps1",
    ".Modules/settings.schema.json"
)

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $fileName = Split-Path $file -Leaf
    $targetPath = Join-Path $cacheDir $fileName

    Write-Host "Downloading $fileName..."
    Invoke-WebRequest -Uri $url -OutFile $targetPath
}

Write-Host "✓ AL-Go helpers cached!" -ForegroundColor Green
```

### Configure Runner Labels

Add custom labels for specific runner capabilities:

```powershell
# During configuration or reconfiguration
.\config.cmd --url https://github.com/YOUR_USERNAME/BCApps --token YOUR_TOKEN --labels self-hosted,Windows,X64,bcapps,fast
```

Then in the workflow, target specific runners:

```yaml
runs-on: [self-hosted, bcapps, fast]
```

### Enable Artifact Caching

Set up a dedicated cache directory:

```powershell
# Create cache directories
New-Item -Path "C:\actions-runner\cache\artifacts" -ItemType Directory -Force
New-Item -Path "C:\actions-runner\cache\nuget" -ItemType Directory -Force
New-Item -Path "C:\actions-runner\cache\al-go" -ItemType Directory -Force

# Set environment variables for runner
[Environment]::SetEnvironmentVariable("ARTIFACTS_CACHE", "C:\actions-runner\cache\artifacts", "Machine")
[Environment]::SetEnvironmentVariable("NUGET_PACKAGES", "C:\actions-runner\cache\nuget", "Machine")
```

### Multiple Runners for Parallel Execution

Set up multiple runners for concurrent workflow runs:

1. Create multiple runner directories:
   ```powershell
   mkdir C:\actions-runner-1
   mkdir C:\actions-runner-2
   mkdir C:\actions-runner-3
   ```

2. Configure each with unique names:
   - bcapps-runner-1
   - bcapps-runner-2
   - bcapps-runner-3

3. Install all as services

4. Workflows will automatically distribute across available runners

## Security Best Practices

### 1. Dedicated Machine
- Use a dedicated machine or VM for the runner
- Don't run on development machines with sensitive data

### 2. Network Isolation
- Place runner in a DMZ or isolated network segment
- Limit outbound network access to required endpoints:
  - github.com
  - api.github.com
  - *.actions.githubusercontent.com
  - BC Admin Center API endpoints
  - Your BC sandbox environment

### 3. Access Control
- Run the service as a dedicated user account (not Administrator)
- Limit repository access to only what's needed
- Use repository-level runners (not organization-level) for better isolation

### 4. Regular Updates
```powershell
# Check for runner updates weekly
cd C:\actions-runner
.\run.cmd --version

# Update if needed (will be prompted during run)
```

### 5. Monitoring
- Monitor runner logs: `C:\actions-runner\_diag\`
- Set up alerts for failed runs
- Review runner activity regularly

## Maintenance

### Updating the Runner

```powershell
# Stop the service
cd C:\actions-runner
.\svc.sh stop

# The runner will prompt to update on next start
.\svc.sh start

# Or manually update
.\config.cmd remove --token YOUR_REMOVAL_TOKEN
# Download new version and reconfigure
```

### Cleaning Up Disk Space

```powershell
# Clean work directory (safe to delete between runs)
Remove-Item -Path "C:\actions-runner\_work\*" -Recurse -Force

# Clean old logs
Remove-Item -Path "C:\actions-runner\_diag\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean cached artifacts (if you set this up)
Remove-Item -Path "C:\actions-runner\cache\artifacts\*" -Recurse -Force
```

### Restart Runner Service

```powershell
# Check status
Get-Service actions.runner.*

# Restart
Restart-Service actions.runner.*

# Or use svc.sh
cd C:\actions-runner
.\svc.sh stop
.\svc.sh start
```

## Troubleshooting

### ❌ Runner is Offline

**Symptoms**: Runner shows as offline in GitHub

**Solutions**:
1. Check service status:
   ```powershell
   Get-Service actions.runner.*
   ```

2. Restart service:
   ```powershell
   Restart-Service actions.runner.*
   ```

3. Check logs:
   ```powershell
   Get-Content C:\actions-runner\_diag\Runner_*.log -Tail 50
   ```

4. Re-register runner if needed

### ❌ Workflow Hangs on Runner

**Symptoms**: Workflow starts but never completes

**Solutions**:
1. Check runner logs during execution
2. Verify network connectivity
3. Ensure sufficient disk space
4. Check PowerShell module versions

### ❌ Permission Errors

**Symptoms**: "Access denied" or permission errors

**Solutions**:
1. Ensure runner service account has necessary permissions
2. Check folder permissions: `C:\actions-runner\_work`
3. Run as Administrator if needed (for initial setup)

### ❌ Module Not Found

**Symptoms**: "Module BcContainerHelper not found"

**Solutions**:
1. Install module globally:
   ```powershell
   Install-Module -Name BcContainerHelper -Scope AllUsers -Force
   ```

2. Verify installation:
   ```powershell
   Get-Module BcContainerHelper -ListAvailable
   ```

### ❌ Out of Disk Space

**Symptoms**: Workflow fails with disk space errors

**Solutions**:
1. Clean work directory regularly
2. Set up scheduled cleanup task:
   ```powershell
   # Create scheduled task to clean weekly
   $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\actions-runner\cleanup.ps1"
   $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
   Register-ScheduledTask -TaskName "CleanupActionsRunner" -Action $action -Trigger $trigger
   ```

## Monitoring and Observability

### View Runner Logs

```powershell
# Real-time logs
Get-Content C:\actions-runner\_diag\Worker_*.log -Wait

# Recent errors
Get-Content C:\actions-runner\_diag\*.log | Select-String "Error" | Select-Object -Last 20
```

### Monitor Performance

```powershell
# CPU and Memory usage
Get-Process -Name "Runner.Listener" | Select-Object CPU, WorkingSet64

# Disk space
Get-PSDrive C | Select-Object Used, Free
```

### Set Up Alerts

Create a monitoring script (`monitor-runner.ps1`):

```powershell
# Check runner service
$service = Get-Service actions.runner.* -ErrorAction SilentlyContinue

if ($service.Status -ne "Running") {
    # Send alert (email, Teams, Slack, etc.)
    Write-Host "ALERT: Runner service is not running!" -ForegroundColor Red
    # Add your notification logic here
}

# Check disk space
$drive = Get-PSDrive C
$freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)

if ($freeSpaceGB -lt 10) {
    Write-Host "ALERT: Low disk space: ${freeSpaceGB}GB free" -ForegroundColor Red
    # Add your notification logic here
}
```

## Cost Analysis

### GitHub-Hosted Runners
- **Cost**: ~$0.008 per minute (Windows)
- **Typical run**: 5-7 minutes
- **Cost per run**: ~$0.04-$0.06
- **100 runs/month**: ~$4-$6

### Self-Hosted Runner
- **Setup cost**: 2-3 hours of time
- **Hardware**: $0 (existing machine) or ~$10-50/month (cloud VM)
- **Operating cost**: Electricity, maintenance
- **Cost per run**: ~$0 (already paid for)
- **100 runs/month**: ~$10-50 (infrastructure only)

**Break-even**: ~20-50 runs/month

## Recommended Setup for BCApps

### Ideal Configuration

```
Hardware:
- CPU: 4+ cores
- RAM: 16GB
- Disk: 100GB SSD
- Network: 100Mbps+

Software:
- Windows 10/11 Pro or Windows Server 2019+
- PowerShell 5.1+
- Git 2.30+
- BcContainerHelper latest
- .NET Framework 4.7.2+

Runner Config:
- Name: bcapps-runner-production
- Labels: self-hosted, Windows, X64, bcapps, production
- Work folder: C:\actions-runner\_work
- Cache: C:\actions-runner\cache
```

### Production Checklist

- [ ] Runner installed as Windows Service
- [ ] Service configured to start automatically
- [ ] BcContainerHelper module installed
- [ ] Git installed and configured
- [ ] Sufficient disk space (100GB+)
- [ ] Network access to BC Admin Center API
- [ ] Firewall rules configured
- [ ] Monitoring set up
- [ ] Backup strategy in place
- [ ] Documentation updated with runner details
- [ ] Team trained on using self-hosted option

## Next Steps

1. **Set up your first runner** following the Quick Start guide
2. **Test with a simple PR** to verify everything works
3. **Monitor performance** and optimize as needed
4. **Scale horizontally** by adding more runners if needed
5. **Document your setup** for team members

## Resources

- [GitHub Self-Hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [BcContainerHelper Documentation](https://github.com/microsoft/navcontainerhelper)
- [AL-Go for GitHub](https://github.com/microsoft/AL-Go)
- [PowerShell Documentation](https://docs.microsoft.com/powershell/)

## Support

For issues with:
- **Runner setup**: Check GitHub's runner documentation
- **Pipeline failures**: Check workflow logs and README troubleshooting
- **BC-specific issues**: Consult BcContainerHelper documentation
- **Performance**: Review this guide's optimization sections

---

**Last Updated**: 2026-03-19
**Version**: 1.0

---

🚀 **Happy (faster) publishing!**
