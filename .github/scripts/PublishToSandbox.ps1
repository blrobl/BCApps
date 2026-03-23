#Requires -Version 7.0
<#
.SYNOPSIS
    Creates launch.json files for BC SaaS Sandbox in workspace folders.

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

function New-LaunchJson {
    param(
        [string] $FolderPath,
        [string] $TenantId,
        [string] $EnvironmentName
    )

    $vscodePath = Join-Path $FolderPath ".vscode"
    $launchPath = Join-Path $vscodePath "launch.json"

    # Create .vscode folder
    if (!(Test-Path $vscodePath)) {
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
    }

    # Create launch.json with AL configuration
    $launchConfig = @{
        "version" = "0.2.0"
        "configurations" = @(
            @{
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
        )
    }

    $launchConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $launchPath -Force
    Write-Host "  ✓ Created: $launchPath" -ForegroundColor Green
}

try {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Creating launch.json for BC Sandbox" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Environment: $EnvironmentName" -ForegroundColor Yellow
    Write-Host "Tenant: $TenantId" -ForegroundColor Yellow
    Write-Host ""

    Push-Location $BaseFolder

    # System Application folders
    $sysAppFolders = @(
        "src/System Application/App"
        "src/System Application/Test"
        "src/System Application/Test Library"
    )

    Write-Host "System Application:" -ForegroundColor White
    foreach ($folder in $sysAppFolders) {
        $fullPath = Join-Path $BaseFolder $folder
        if (Test-Path $fullPath) {
            New-LaunchJson -FolderPath $fullPath -TenantId $TenantId -EnvironmentName $EnvironmentName
        } else {
            Write-Host "  ⚠ Skipped (not found): $folder" -ForegroundColor Yellow
        }
    }
    Write-Host ""

    # Business Foundation folders
    $bizFoundFolders = @(
        "src/Business Foundation/App"
        "src/Business Foundation/Test"
        "src/Business Foundation/Test Library"
    )

    Write-Host "Business Foundation:" -ForegroundColor White
    foreach ($folder in $bizFoundFolders) {
        $fullPath = Join-Path $BaseFolder $folder
        if (Test-Path $fullPath) {
            New-LaunchJson -FolderPath $fullPath -TenantId $TenantId -EnvironmentName $EnvironmentName
        } else {
            Write-Host "  ⚠ Skipped (not found): $folder" -ForegroundColor Yellow
        }
    }
    Write-Host ""

    Write-Host "============================================" -ForegroundColor Green
    Write-Host "✓ Configuration Complete!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press F5 in any folder to publish and debug!" -ForegroundColor Cyan
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
