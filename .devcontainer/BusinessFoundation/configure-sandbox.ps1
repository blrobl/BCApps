#!/usr/bin/env pwsh

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuring Sandbox Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if sandbox config exists (in the current workspace folder)
$configPath = ".sandbox-config.json"
if (-not (Test-Path $configPath)) {
    Write-Host "⚠️  No sandbox configuration found" -ForegroundColor Yellow
    Write-Host "This branch wasn't created by the sandbox workflow." -ForegroundColor Gray
    Write-Host ""
    exit 0
}

# Read configuration
Write-Host "Reading sandbox configuration..." -ForegroundColor Gray
$config = Get-Content $configPath | ConvertFrom-Json

Write-Host "Environment Details:" -ForegroundColor Yellow
Write-Host "  Tenant ID: $($config.tenantId)" -ForegroundColor Gray
Write-Host "  Environment: $($config.environmentName)" -ForegroundColor Gray
Write-Host "  Country: $($config.country)" -ForegroundColor Gray
Write-Host "  PR Number: $($config.prNumber)" -ForegroundColor Gray
Write-Host ""

# Run the configuration script (relative to workspace folder)
$scriptPath = "../../.github/scripts/PublishToSandbox.ps1"
if (-not (Test-Path $scriptPath)) {
    Write-Host "✗ Configuration script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Configuring launch.json files..." -ForegroundColor Yellow
& $scriptPath `
    -TenantId $config.tenantId `
    -EnvironmentName $config.environmentName `
    -Country $config.country `
    -BaseFolder "../.."

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Sandbox environment configured!" -ForegroundColor Green
    Write-Host "   Press F5 to publish and debug" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "✗ Configuration failed" -ForegroundColor Red
    exit 1
}
