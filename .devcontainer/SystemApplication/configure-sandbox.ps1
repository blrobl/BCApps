#!/usr/bin/env pwsh

# Sandbox configuration (filled by workflow)
$tenantId = "f0ac72d1-c1b3-4c2a-a196-8fb82cac5934"
$environmentName = "a47676_p47575_US_29-0-cdsb"
$country = "us"
$prNumber = "1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuring Sandbox Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if this was configured by the workflow
if ($tenantId -eq "f0ac72d1-c1b3-4c2a-a196-8fb82cac5934") {
    Write-Host "⚠️  No sandbox configuration found" -ForegroundColor Yellow
    Write-Host "This branch wasn't created by the sandbox workflow." -ForegroundColor Gray
    Write-Host ""
    exit 0
}

Write-Host "Environment Details:" -ForegroundColor Yellow
Write-Host "  Tenant ID: $tenantId" -ForegroundColor Gray
Write-Host "  Environment: $environmentName" -ForegroundColor Gray
Write-Host "  Country: $country" -ForegroundColor Gray
Write-Host "  PR Number: $prNumber" -ForegroundColor Gray
Write-Host ""

# Run the configuration script (relative to workspace folder)
$scriptPath = "../../.github/scripts/PublishToSandbox.ps1"
if (-not (Test-Path $scriptPath)) {
    Write-Host "✗ Configuration script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Configuring launch.json files..." -ForegroundColor Yellow
& $scriptPath `
    -TenantId $tenantId `
    -EnvironmentName $environmentName `
    -Country $country `
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
