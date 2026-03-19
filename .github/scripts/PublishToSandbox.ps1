<#
.SYNOPSIS
    Publishes System Application and Business Foundation apps to a Business Central SaaS Sandbox environment.

.DESCRIPTION
    This script configures VSCode launch.json files for cloud sandbox development and publishes
    the System Application and Business Foundation apps to a specified BC SaaS environment.

.PARAMETER TenantId
    The Microsoft Entra (Azure AD) tenant ID for authentication.

.PARAMETER EnvironmentName
    The name of the Business Central SaaS sandbox environment.

.PARAMETER Country
    The country/region code for the environment (e.g., 'us', 'gb', 'dk').

.PARAMETER BaseFolder
    The root folder of the BCApps repository. Defaults to the current directory.

.PARAMETER SkipPublish
    If specified, only configures launch.json without publishing apps.

.EXAMPLE
    .\PublishToSandbox.ps1 -TenantId "f0ac72d1-c1b3-4c2a-a196-8fb82cac5934" `
                           -EnvironmentName "a47676_p47575_US_29-0-cdsb" `
                           -Country "us"
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
    [string] $BaseFolder = $PSScriptRoot,

    [Parameter(Mandatory = $false)]
    [switch] $SkipPublish
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Helper function to download AL-Go helper files
function Download-ALGoHelper {
    param(
        [string] $Url,
        [string] $TargetFolder
    )

    $fileName = [System.IO.Path]::GetFileName($Url)
    $targetPath = Join-Path $TargetFolder $fileName

    if (Test-Path $targetPath) {
        Write-Host "  $fileName already exists" -ForegroundColor Gray
        return $targetPath
    }

    Write-Host "  Downloading $fileName..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $Url -OutFile $targetPath -UseBasicParsing
    }
    catch {
        Write-Host "  Failed to download $fileName, trying authenticated download..." -ForegroundColor Yellow
        $token = gh auth token
        Invoke-WebRequest -Uri $Url -OutFile $targetPath -UseBasicParsing -Headers @{ "Authorization" = "token $token" }
    }

    return $targetPath
}

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

    if ($SkipPublish) {
        Write-Host "Skipping app publishing (SkipPublish flag set)" -ForegroundColor Yellow
        return
    }

    # Publishing apps to cloud environment
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Publishing Apps to Cloud Environment" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # Create temporary folder for AL-Go helpers
    $tempFolder = Join-Path ([System.IO.Path]::GetTempPath()) "ALGoHelpers-$(New-Guid)"
    New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null

    Write-Host "Downloading AL-Go helper modules..." -ForegroundColor Yellow

    # AL-Go version to use (same as in cloudDevEnv.ps1)
    $alGoVersion = "91c2f1bab7959cffc66fd9513a1d83ec9f641e30"
    $baseUrl = "https://raw.githubusercontent.com/microsoft/AL-Go/$alGoVersion/Actions"

    # Download required modules
    $githubHelper = Download-ALGoHelper -Url "$baseUrl/Github-Helper.psm1" -TargetFolder $tempFolder
    $readSettings = Download-ALGoHelper -Url "$baseUrl/.Modules/ReadSettings.psm1" -TargetFolder $tempFolder
    $debugLogging = Download-ALGoHelper -Url "$baseUrl/.Modules/DebugLogHelper.psm1" -TargetFolder $tempFolder
    $alGoHelper = Download-ALGoHelper -Url "$baseUrl/AL-Go-Helper.ps1" -TargetFolder $tempFolder
    Download-ALGoHelper -Url "$baseUrl/.Modules/settings.schema.json" -TargetFolder $tempFolder | Out-Null

    Write-Host ""
    Write-Host "Importing AL-Go modules..." -ForegroundColor Yellow
    Import-Module $githubHelper -DisableNameChecking
    Import-Module $readSettings -DisableNameChecking
    Import-Module $debugLogging -DisableNameChecking
    . $alGoHelper -local

    Write-Host ""
    Write-Host "Setting up AL-Go projects..." -ForegroundColor Yellow

    # Get base folder and project
    $alGoBaseFolder = GetBaseFolder -folder (Join-Path $BaseFolder "build\projects\System Application\.AL-Go")
    $project = GetProject -baseFolder $alGoBaseFolder -projectALGoFolder (Join-Path $BaseFolder "build\projects\System Application\.AL-Go")

    Write-Host "  Base folder: $alGoBaseFolder" -ForegroundColor Gray
    Write-Host "  Project: $project" -ForegroundColor Gray
    Write-Host ""

    # Custom settings for the environment
    $customSettings = @{
        "country" = $Country
    } | ConvertTo-Json -Compress

    Write-Host "Publishing to environment..." -ForegroundColor Yellow
    Write-Host "  Tenant: $TenantId" -ForegroundColor Gray
    Write-Host "  Environment: $EnvironmentName" -ForegroundColor Gray
    Write-Host "  Country: $Country" -ForegroundColor Gray
    Write-Host ""

    # Note: Authentication is required via ADMIN_CENTER_API_CREDENTIALS secret
    # The CreateDevEnv function handles the publishing automatically
    Write-Host "Calling AL-Go CreateDevEnv function..." -ForegroundColor Yellow

    CreateDevEnv `
        -kind cloud `
        -caller local `
        -environmentName $EnvironmentName `
        -reuseExistingEnvironment $true `
        -baseFolder $alGoBaseFolder `
        -project $project `
        -clean $false `
        -customSettings $customSettings

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "✓ Publishing Complete!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Apps published:" -ForegroundColor White
    Write-Host "  ✓ System Application" -ForegroundColor Green
    Write-Host "  ✓ Business Foundation" -ForegroundColor Green
    Write-Host ""
    Write-Host "Launch.json files configured in:" -ForegroundColor White
    Write-Host "  - $systemAppWorkspace\.vscode\launch.json" -ForegroundColor Gray
    Write-Host "  - $businessFoundationWorkspace\.vscode\launch.json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To use the configured environment:" -ForegroundColor Yellow
    Write-Host "  1. Open one of the workspace folders in VS Code" -ForegroundColor Gray
    Write-Host "  2. Press F5 or select 'Cloud Sandbox ($EnvironmentName)' from the debug configurations" -ForegroundColor Gray
    Write-Host "  3. Sign in with your Microsoft Entra credentials when prompted" -ForegroundColor Gray
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

    # Cleanup temporary folder
    if (Test-Path $tempFolder) {
        Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}
