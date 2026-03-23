#Requires -Version 7.0
<#
.SYNOPSIS
    Creates launch.json files for BC SaaS Sandbox in all AL projects.
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
        [string] $ProjectFolder,
        [string] $TenantId,
        [string] $EnvironmentName
    )

    Write-Host "  Configuring: $ProjectFolder" -ForegroundColor Gray

    $vscodePath = Join-Path $ProjectFolder ".vscode"
    $launchPath = Join-Path $vscodePath "launch.json"

    # Create .vscode folder
    if (!(Test-Path $vscodePath)) {
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
        Write-Host "    Created .vscode folder" -ForegroundColor DarkGray
    }

    # Create launch.json
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
    Write-Host "    ✓ Created launch.json" -ForegroundColor Green
}

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

    # Find all AL projects in System Application and Business Foundation
    $folders = @("src/System Application", "src/Business Foundation")

    foreach ($folder in $folders) {
        $fullPath = Join-Path $BaseFolder $folder
        if (!(Test-Path $fullPath)) {
            Write-Host "⚠ Folder not found: $folder" -ForegroundColor Yellow
            continue
        }

        Write-Host "Searching for AL projects in: $folder" -ForegroundColor White

        # Find all folders with app.json (AL projects)
        $projects = Get-ChildItem -Path $fullPath -Recurse -File -Filter "app.json" |
            ForEach-Object { $_.Directory.FullName }

        if ($projects.Count -eq 0) {
            Write-Host "  No AL projects found" -ForegroundColor Yellow
        }

        foreach ($project in $projects) {
            New-LaunchJson -ProjectFolder $project -TenantId $TenantId -EnvironmentName $EnvironmentName
        }

        Write-Host ""
    }

    Write-Host "============================================" -ForegroundColor Green
    Write-Host "✓ Configuration Complete!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""

    exit 0
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack trace:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    Write-Host ""

    exit 1
}
finally {
    Pop-Location
}
