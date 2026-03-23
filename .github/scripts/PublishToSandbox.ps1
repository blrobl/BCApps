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

# Import AL Dev utilities
Import-Module (Join-Path $BaseFolder "build\scripts\DevEnv\ALDev.psm1") -DisableNameChecking -Force

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

    # Find and configure all AL projects in System Application and Business Foundation
    $folders = @(
        "src/System Application"
        "src/Business Foundation"
    )

    foreach ($folder in $folders) {
        $fullPath = Join-Path $BaseFolder $folder
        if (Test-Path $fullPath) {
            Write-Host "Configuring projects in: $folder" -ForegroundColor White

            # Find all app.json files (AL projects)
            $appFolders = Get-ChildItem $fullPath -Directory -Recurse |
                Where-Object { Test-Path (Join-Path $_.FullName "app.json") } |
                ForEach-Object { $_.FullName }

            foreach ($appFolder in $appFolders) {
                $relativePath = $appFolder.Replace("$BaseFolder\", "").Replace($BaseFolder + "\", "")
                Write-Host "  → $relativePath" -ForegroundColor Gray
                Configure-ALProject -ProjectFolder $appFolder -LaunchSettings $launchSettings -ProjectSettings @{}
            }
            Write-Host ""
        }
    }

    Write-Host "============================================" -ForegroundColor Green
    Write-Host "✓ Configuration Complete!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press F5 in any AL project to publish!" -ForegroundColor Cyan
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "✗ Error occurred" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    throw
}
finally {
    Pop-Location
}
