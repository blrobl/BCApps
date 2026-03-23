# BC Sandbox Publisher - Codespaces Configuration

This devcontainer configuration enables one-click testing of PRs in BC SaaS Sandbox using GitHub Codespaces.

## What It Does

When you open this configuration in Codespaces:

1. ✅ Creates Ubuntu-based development environment
2. ✅ Installs AL Language extension automatically
3. ✅ Configures PowerShell
4. ✅ Sets up Git
5. ✅ Creates welcome file with instructions
6. ✅ Ready to press F5 and publish!

## How to Use

### From PR Comment

1. Pipeline runs and configures launch.json
2. PR comment includes "Open in Codespaces" button
3. Click button → Codespaces opens automatically
4. Wait ~2-3 minutes for environment setup
5. Open workspace and press F5!

### Manual Launch

```
https://codespaces.new/<owner>/BCApps/tree/<branch>?devcontainer_path=.devcontainer/sandbox-publisher/devcontainer.json
```

## What's Configured

### Pre-installed Extensions
- `ms-dynamics-smb.al` - AL Language extension

### Settings
- Code analysis enabled (CodeCop, UICop, PerTenantExtensionCop)
- Auto-save enabled

### Post-Create Script
- Installs system dependencies
- Creates CODESPACES-README.md with instructions
- Shows welcome message

### Tasks Available
- **Publish to BC Sandbox** - Shows instructions
- **Open System Application Workspace** - Opens workspace
- **Open Business Foundation Workspace** - Opens workspace

## Files

```
.devcontainer/sandbox-publisher/
├── devcontainer.json       # Main configuration
├── post-create.sh          # Setup script
├── tasks.json              # VS Code tasks
└── README.md               # This file
```

## Workflow Integration

The PR publishing workflow automatically:
1. Configures launch.json for the sandbox
2. Posts PR comment with Codespaces button
3. Creates workflow summary with Codespaces link
4. Branch includes this devcontainer config

## Usage in Codespaces

### First Time
1. Click "Open in Codespaces" from PR comment
2. Wait for Codespaces to boot (~2-3 min)
3. Read CODESPACES-README.md that opens automatically
4. Open a workspace:
   - `src/System Application/SystemApplication.code-workspace`
   - `src/Business Foundation/BusinessFoundation.code-workspace`
5. Press F5
6. Sign in with Microsoft Entra credentials
7. Wait for app to publish (~2-3 min first time)
8. Start debugging!

### Subsequent Times
1. Open Codespaces (much faster - ~30 sec)
2. Press F5 (faster - credentials cached)
3. Debug!

## Cost Considerations

### Codespaces Usage
- Free tier: 120 core-hours/month, 15 GB-months storage
- This container: ~2 cores = 60 hours free/month
- Paid: ~$0.18/hour for 2-core machine

### When to Use
- **Use Codespaces when:**
  - Testing PRs from microsoft/BCApps
  - Quick one-time tests
  - No local BC setup
  - Working from browser/tablet

- **Use local VS Code when:**
  - Regular development
  - Multiple daily publishes
  - Have local BC setup
  - Want faster performance

## Customization

### Add More Extensions

Edit `devcontainer.json`:
```json
"extensions": [
  "ms-dynamics-smb.al",
  "GitHub.copilot",
  "your-extension-id"
]
```

### Change Machine Type

Add to `devcontainer.json`:
```json
"hostRequirements": {
  "cpus": 4,
  "memory": "8gb",
  "storage": "32gb"
}
```

### Pre-install Tools

Edit `post-create.sh`:
```bash
# Install additional tools
sudo apt-get install -y your-tool
```

## Troubleshooting

### Codespaces Won't Start
- Check repository permissions
- Verify devcontainer.json syntax
- Check Codespaces quota/billing

### AL Extension Not Working
- Restart Codespaces
- Check extension installation in post-create.sh output
- Manually install: Extensions → Search "AL" → Install

### Can't Sign In to BC
- Ensure popup blockers are disabled
- Try: `Ctrl+Shift+P` → `AL: Sign out` → Try again
- Check you have access to the BC environment

### Publishing Fails
- Check Output panel: View → Output → "AL Language"
- Verify BC environment is running (not suspended)
- Check app dependencies are met

## Resources

- [Devcontainers Spec](https://containers.dev/)
- [Codespaces Docs](https://docs.github.com/codespaces)
- [AL Extension Docs](https://docs.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-dev-overview)

## Support

For issues:
- Devcontainer problems: Check post-create.sh logs
- AL extension issues: Check Output → AL Language
- BC publishing issues: Check BC Admin Center

---

**Created**: Part of PR publishing pipeline
**Purpose**: One-click BC SaaS testing
**Maintained**: Automatically by pipeline
