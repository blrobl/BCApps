#Requires -Version 7.0
<#
.SYNOPSIS
    Creates launch.json files for BC SaaS Sandbox in all AL projects.

.PARAMETER TenantId
    The Microsoft Entra tenant ID.

.PARAMETER EnvironmentName
    The BC SaaS sandbox environment name.

.PARAMETER Country
    The country code (e.g., 'us').

.PARAMETER BaseFolder
    The repository root folder.
#>

param(
    [Parameter(Mandatory = $true)]
    [string] $TenantId,

    [Parameter(Mandatory = $true)]
    [string] $EnvironmentName,

    [Parameter(Mandatory = $false)]
    [string] $Country = "us",

    [Parameter(Mandatory = $false)]
    [string] $BaseFolder = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

try {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Configuring AL Projects for Cloud Sandbox" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Environment: $EnvironmentName" -ForegroundColor Yellow
    Write-Host "Tenant: $TenantId" -ForegroundColor Yellow
    Write-Host ""

    Push-Location $BaseFolder

    # Import AL Dev utilities
    $alDevModule = Join-Path $BaseFolder "build\scripts\DevEnv\ALDev.psm1"
    Import-Module $alDevModule -DisableNameChecking -Force -ErrorAction Stop

    # Cloud Sandbox launch settings
    $launchSettings = @{
        "type" = "al"
        "request" = "launch"
        "name" = "Cloud Sandbox ($EnvironmentName)"
        "environmentType" = "Sandbox"
        "environmentName" = $EnvironmentName
        "tenant" = $TenantId
        "authentication" = "AAD"
        "startupObjectType" = "Page"
        "startupObjectId" = 22
        "schemaUpdateMode" = "Synchronize"
        "breakOnError" = $true
        "launchBrowser" = $true
        "enableLongRunningSqlStatements" = $true
        "enableSqlInformationDebugger" = $true
    }

    # Configure System Application
    Write-Host "Configuring System Application projects..." -ForegroundColor White
    Configure-ALProjectsInPath -Path (Join-Path $BaseFolder "src/System Application") -LaunchSettings $launchSettings -ProjectSettings @{}
    Write-Host ""

    # Configure Business Foundation
    Write-Host "Configuring Business Foundation projects..." -ForegroundColor White
    Configure-ALProjectsInPath -Path (Join-Path $BaseFolder "src/Business Foundation") -LaunchSettings $launchSettings -ProjectSettings @{}
    Write-Host ""

    Write-Host "============================================" -ForegroundColor Green
    Write-Host "✓ Configuration Complete!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press F5 in any AL project to publish!" -ForegroundColor Cyan
    Write-Host ""

    # Explicitly exit with success
    exit 0
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "✗ Error occurred" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack: $($_.ScriptStackTrace)" -ForegroundColor Yellow
    Write-Host ""

    # Explicitly exit with error
    exit 1
}
finally {
    Pop-Location
}
