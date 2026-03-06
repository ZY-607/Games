# Wuxia Survivor - One-Click Upload Script v1.3
# Usage: .\upload.ps1 -Message "your commit message"

param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Wuxia Survivor - Upload Script v1.3" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($scriptDir) {
    Set-Location $scriptDir
}

# Step 1: Check Git config
Write-Host "[1/6] Checking Git config..." -ForegroundColor Green
$gitName = git config user.name 2>$null
$gitEmail = git config user.email 2>$null
if (-not $gitName -or -not $gitEmail) {
    Write-Host "Configuring Git user info..." -ForegroundColor Yellow
    git config user.name "WuxiaDeveloper"
    git config user.email "developer@wuxia.local"
    Write-Host "Git user info configured" -ForegroundColor Green
}

# Step 2: Check Git status
Write-Host "[2/6] Checking Git status..." -ForegroundColor Green
$status = git status --porcelain 2>$null
if ($status.Count -eq 0) {
    Write-Host "No changes to commit!" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Found $($status.Count) changed file(s):" -ForegroundColor White
$status | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
Write-Host ""

# Step 3: Add all changes
Write-Host "[3/6] Adding all changes..." -ForegroundColor Green
git add -A 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to add files!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Files added to staging area" -ForegroundColor Green

# Step 4: Create commit
Write-Host "[4/6] Creating commit..." -ForegroundColor Green
if ($Message -eq "") {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "Update: $date"
}

$commitOutput = git commit -m $Message 2>&1
if ($LASTEXITCODE -ne 0) {
    if ($commitOutput -match "nothing to commit") {
        Write-Host "No changes to commit!" -ForegroundColor Yellow
    } else {
        Write-Host "Commit failed: $commitOutput" -ForegroundColor Red
    }
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Commit successful: $Message" -ForegroundColor Green

# Step 5: Get current branch
Write-Host "[5/6] Getting current branch..." -ForegroundColor Green
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $branch" -ForegroundColor White

# Step 6: Push to GitHub
Write-Host "[6/6] Pushing to GitHub..." -ForegroundColor Green
$pushOutput = git push -u origin $branch 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push failed!" -ForegroundColor Red
    Write-Host "Error: $pushOutput" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "  1. Network connection issue" -ForegroundColor White
    Write-Host "  2. GitHub authentication required" -ForegroundColor White
    Write-Host "  3. Remote repository permission issue" -ForegroundColor White
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "          Upload Successful!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Branch: $branch" -ForegroundColor White
Write-Host "  Commit: $Message" -ForegroundColor White
Write-Host ""
Write-Host "  GitHub: https://github.com/ZY-607/Games/tree/wuxia-survivor" -ForegroundColor Blue
Write-Host ""

Read-Host "Press Enter to exit"
