# Wuxia Survivor - One-Click Upload Script v1.5
# Usage: .\upload.ps1 -Message "your commit message"
# This script always pushes to 'main' branch for GitHub Pages

param(
    [string]$Message = ""
)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Wuxia Survivor - Upload Script v1.5" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($scriptDir) {
    Set-Location $scriptDir
}

# Step 1: Check Git config
Write-Host "[1/7] Checking Git config..." -ForegroundColor Green
$gitName = git config user.name 2>$null
$gitEmail = git config user.email 2>$null
if (-not $gitName -or -not $gitEmail) {
    Write-Host "Configuring Git user info..." -ForegroundColor Yellow
    git config user.name "WuxiaDeveloper"
    git config user.email "developer@wuxia.local"
    Write-Host "Git user info configured" -ForegroundColor Green
}

# Step 2: Switch to main branch
Write-Host "[2/7] Switching to main branch..." -ForegroundColor Green
git checkout main 2>&1 | Out-Null
Write-Host "Now on main branch" -ForegroundColor Green

# Step 3: Check Git status
Write-Host "[3/7] Checking Git status..." -ForegroundColor Green
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

# Step 4: Add all changes
Write-Host "[4/7] Adding all changes..." -ForegroundColor Green
git add -A 2>&1 | Out-Null
Write-Host "Files added to staging area" -ForegroundColor Green

# Step 5: Create commit
Write-Host "[5/7] Creating commit..." -ForegroundColor Green
if ($Message -eq "") {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "Update: $date"
}

git commit -m $Message 2>&1 | Out-Null
Write-Host "Commit successful: $Message" -ForegroundColor Green

# Step 6: Setup main branch tracking
Write-Host "[6/7] Setting up branch tracking..." -ForegroundColor Green
git branch --set-upstream-to=origin/main main 2>&1 | Out-Null
Write-Host "Branch tracking configured" -ForegroundColor Green

# Step 7: Push to GitHub
Write-Host "[7/7] Pushing to GitHub (main branch)..." -ForegroundColor Green
git push -u origin main 2>&1 | Out-Null
$pushExitCode = $LASTEXITCODE

if ($pushExitCode -ne 0) {
    Write-Host "Push failed! Exit code: $pushExitCode" -ForegroundColor Red
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
Write-Host "  Branch: main" -ForegroundColor White
Write-Host "  Commit: $Message" -ForegroundColor White
Write-Host ""
Write-Host "  GitHub: https://github.com/ZY-607/Games" -ForegroundColor Blue
Write-Host "  Game:   https://zy-607.github.io/Games/" -ForegroundColor Blue
Write-Host ""

Read-Host "Press Enter to exit"
