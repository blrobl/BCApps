#!/bin/bash
set -e

echo "🚀 Setting up BC Sandbox Publisher environment..."

# Install AL Language extension dependencies
echo "📦 Installing dependencies..."
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common

echo "✅ Environment setup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Ready to publish to BC Sandbox!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Open workspace:"
echo "     • System Application: src/System Application/SystemApplication.code-workspace"
echo "     • Business Foundation: src/Business Foundation/BusinessFoundation.code-workspace"
echo ""
echo "  2. Press F5 to publish and debug in the sandbox"
echo ""
echo "  3. Sign in with your Microsoft Entra credentials when prompted"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create a welcome file with instructions
cat > /workspaces/BCApps/CODESPACES-README.md << 'EOF'
# 🚀 BC Sandbox Publisher - Codespaces

Welcome to your pre-configured Codespaces environment!

## ✅ What's Configured

- ✅ AL Language extension installed
- ✅ Launch.json configured for your sandbox environment
- ✅ PowerShell ready
- ✅ Git configured

## 🎯 How to Publish Apps

### Option 1: Using VS Code (Recommended)

1. **Open a workspace:**
   - Click: `src/System Application/SystemApplication.code-workspace`
   - OR: `src/Business Foundation/BusinessFoundation.code-workspace`

2. **Press F5** (or Run → Start Debugging)

3. **Sign in** with your Microsoft Entra credentials when prompted

4. **Wait for publishing** (2-3 minutes first time)

5. **Start debugging!** The browser will open to your sandbox

### Option 2: Using Tasks

1. Open Command Palette: `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)

2. Type: `Tasks: Run Task`

3. Select: `Publish to BC Sandbox`

4. Sign in when prompted

## 📂 Workspaces Available

- **System Application**: `src/System Application/SystemApplication.code-workspace`
- **Business Foundation**: `src/Business Foundation/BusinessFoundation.code-workspace`

## 🔍 Launch Configuration

Your launch.json is configured with:
- Environment: Check the workflow output for details
- Authentication: Microsoft Entra (Azure AD)
- Mode: Publish and debug

## 💡 Tips

- **First time sign-in**: You'll be prompted to authenticate to BC Admin Center
- **Cached credentials**: After first sign-in, publishing is faster
- **Debugging**: Breakpoints work just like local debugging
- **Browser**: BC Web Client opens automatically after publishing

## 🆘 Troubleshooting

### Sign-in Issues
- Ensure you have access to the BC environment
- Check that your Microsoft account has permissions
- Try signing out and back in: `Ctrl+Shift+P` → `AL: Sign out`

### Publishing Errors
- Check the Output panel: View → Output → Select "AL Language"
- Verify app dependencies are met
- Ensure BC environment is running (not suspended)

## 📚 Resources

- [AL Language Extension Docs](https://docs.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-dev-overview)
- [GitHub Codespaces Docs](https://docs.github.com/codespaces)

---

**Note**: This environment was automatically configured by the PR publishing pipeline.
Apps are NOT automatically published - use F5 or tasks to publish when ready.
EOF

echo "📝 Created CODESPACES-README.md with detailed instructions"
echo ""
echo "✨ Setup complete! Happy coding! ✨"
