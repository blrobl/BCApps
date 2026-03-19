<#
.SYNOPSIS
    Configures VSCode launch.json files for a Business Central SaaS Sandbox environment.

.DESCRIPTION
    This script configures VSCode launch.json files for cloud sandbox development,
    enabling you to press F5 in VS Code to publish and debug apps in your BC SaaS environment.

.PARAMETER TenantId
    The Microsoft Entra (Azure AD) tenant ID for authentication.

.PARAMETER EnvironmentName
    The name of the Business Central SaaS sandbox environment.

.PARAMETER Country
    The country/region code for the environment (e.g., 'us', 'gb', 'dk').

.PARAMETER BaseFolder
    The root folder of the BCApps repository. Defaults to the current directory.

.EXAMPLE
    .\PublishToSandbox.ps1 -TenantId "f0ac72d1-c1b3-4c2a-a196-8fb82cac5934" `
                           -EnvironmentName "a47676_p47575_US_29-0-cdsb" `
                           -Country "us"

.NOTES
    This script only configures launch.json files. It does NOT automatically publish apps.
    To publish apps, use F5 in VS Code after checking out the configured branch.
#>

[CmdletBinding()]
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
$ProgressPreference = "SilentlyContinue"

# Helper function to create launch.json configuration for cloud sandbox
function New-CloudSandboxLaunchConfig {
    param(
        [string] $WorkspacePath,
        [string] $ConfigName,
        [string] $TenantId,
        [string] $EnvironmentName
    )

    $vscodePath = Join-Path $WorkspacePath ".vscode"
    $launchPath = Join-Path $vscodePath "launch.json"

    # Ensure .vscode directory exists
    if (!(Test-Path $vscodePath)) {
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
    }

    # Create cloud sandbox configuration
    $cloudConfig = @{
        "type" = "al"
        "request" = "launch"
        "name" = $ConfigName
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
        "dependencyPublishingOption" = "Ignore"
    }

    # Read existing launch.json or create new one
    $launchConfig = @{
        "version" = "0.2.0"
        "configurations" = @()
    }

    if (Test-Path $launchPath) {
        try {
            $existingContent = Get-Content $launchPath -Raw | ConvertFrom-Json
            $launchConfig = $existingContent

            # Remove existing cloud sandbox config if it exists
            $launchConfig.configurations = @($launchConfig.configurations | Where-Object {
                $_.name -ne $ConfigName
            })
        }
        catch {
            Write-Host "  Warning: Could not parse existing launch.json, creating new one" -ForegroundColor Yellow
        }
    }

    # Add new cloud sandbox configuration
    $launchConfig.configurations = @($launchConfig.configurations) + $cloudConfig

    # Save launch.json
    $launchConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $launchPath -Force

    Write-Host "  ✓ Created launch configuration: $ConfigName" -ForegroundColor Green
    Write-Host "    Path: $launchPath" -ForegroundColor Gray
}

# Main script execution
try {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Publish to BC SaaS Sandbox Environment" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # Navigate to base folder
    if (!(Test-Path $BaseFolder)) {
        throw "Base folder not found: $BaseFolder"
    }

    Push-Location $BaseFolder

    # Workspace paths
    $systemAppWorkspace = Join-Path $BaseFolder "src\System Application"
    $businessFoundationWorkspace = Join-Path $BaseFolder "src\Business Foundation"

    Write-Host "Configuring VSCode workspaces..." -ForegroundColor Yellow
    Write-Host ""

    # Configure launch.json for System Application
    Write-Host "System Application:" -ForegroundColor White
    if (Test-Path $systemAppWorkspace) {
        New-CloudSandboxLaunchConfig `
            -WorkspacePath $systemAppWorkspace `
            -ConfigName "Cloud Sandbox ($EnvironmentName)" `
            -TenantId $TenantId `
            -EnvironmentName $EnvironmentName
    }
    else {
        Write-Host "  Warning: System Application workspace not found at $systemAppWorkspace" -ForegroundColor Yellow
    }
    Write-Host ""

    # Configure launch.json for Business Foundation
    Write-Host "Business Foundation:" -ForegroundColor White
    if (Test-Path $businessFoundationWorkspace) {
        New-CloudSandboxLaunchConfig `
            -WorkspacePath $businessFoundationWorkspace `
            -ConfigName "Cloud Sandbox ($EnvironmentName)" `
            -TenantId $TenantId `
            -EnvironmentName $EnvironmentName
    }
    else {
        Write-Host "  Warning: Business Foundation workspace not found at $businessFoundationWorkspace" -ForegroundColor Yellow
    }
    Write-Host ""

    # Note: Skipping automatic app publishing
    # Apps can be published by pressing F5 in VS Code with the configured launch.json

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "✓ Configuration Complete!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Launch.json files configured:" -ForegroundColor White
    Write-Host "  ✓ src\System Application\.vscode\launch.json" -ForegroundColor Gray
    Write-Host "  ✓ src\Business Foundation\.vscode\launch.json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Environment configured:" -ForegroundColor White
    Write-Host "  • Tenant ID: $TenantId" -ForegroundColor Gray
    Write-Host "  • Environment: $EnvironmentName" -ForegroundColor Gray
    Write-Host "  • Country: $Country" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Next Steps (on your local machine):" -ForegroundColor Yellow
    Write-Host "  1. Fetch and checkout the configured branch:" -ForegroundColor Gray
    Write-Host "     git fetch && git checkout <branch-name>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Open workspace in VS Code:" -ForegroundColor Gray
    Write-Host "     code `"src\System Application\SystemApplication.code-workspace`"" -ForegroundColor Cyan
    Write-Host "     OR" -ForegroundColor Gray
    Write-Host "     code `"src\Business Foundation\BusinessFoundation.code-workspace`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. Press F5 to publish and debug in the sandbox" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  4. Sign in with Microsoft Entra credentials when prompted" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Note: Apps are NOT automatically published by this pipeline." -ForegroundColor Cyan
    Write-Host "      Use F5 in VS Code to publish to the configured environment." -ForegroundColor Cyan
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
    Write-Host "Stack trace:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    Write-Host ""

    # If authentication error, provide helpful guidance
    if ($_.Exception.Message -like "*authentication*" -or $_.Exception.Message -like "*credentials*") {
        Write-Host "Note: This script requires authentication to BC Admin Center API." -ForegroundColor Yellow
        Write-Host "Please ensure ADMIN_CENTER_API_CREDENTIALS secret is configured." -ForegroundColor Yellow
        Write-Host "See: https://aka.ms/algosettings for more information." -ForegroundColor Yellow
        Write-Host ""
    }

    throw
}
finally {
    Pop-Location
}
