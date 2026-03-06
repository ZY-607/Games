<#
.SYNOPSIS
    武侠幸存者项目一键上传脚本
.DESCRIPTION
    自动将项目更改提交并推送到GitHub
.PARAMETER Message
    提交信息（可选，默认为日期时间格式）
.EXAMPLE
    .\upload.ps1
    .\upload.ps1 -Message "新增功能XXX"
#>

param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  武侠幸存者 - 一键上传脚本 v1.2" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($scriptDir) {
    Set-Location $scriptDir
}

Write-Host "[1/6] 检查Git配置..." -ForegroundColor Green
$gitName = git config user.name 2>$null
$gitEmail = git config user.email 2>$null
if (-not $gitName -or -not $gitEmail) {
    Write-Host "正在配置Git用户信息..." -ForegroundColor Yellow
    git config user.name "WuxiaDeveloper"
    git config user.email "developer@wuxia.local"
    Write-Host "Git用户信息已配置" -ForegroundColor Green
}

Write-Host "[2/6] 检查Git状态..." -ForegroundColor Green
$status = git status --porcelain 2>$null
if ($status.Count -eq 0) {
    Write-Host "没有需要提交的更改！" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    exit 0
}

Write-Host "发现 $($status.Count) 个更改文件:" -ForegroundColor White
$status | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
Write-Host ""

Write-Host "[3/6] 添加所有更改..." -ForegroundColor Green
git add -A 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "添加文件失败！" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}
Write-Host "文件已添加到暂存区" -ForegroundColor Green

Write-Host "[4/6] 创建提交..." -ForegroundColor Green
if ($Message -eq "") {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "Update: $date"
}

$commitOutput = git commit -m $Message 2>&1
if ($LASTEXITCODE -ne 0) {
    if ($commitOutput -match "nothing to commit") {
        Write-Host "没有需要提交的更改！" -ForegroundColor Yellow
    } else {
        Write-Host "提交失败: $commitOutput" -ForegroundColor Red
    }
    Read-Host "按回车键退出"
    exit 1
}
Write-Host "提交成功: $Message" -ForegroundColor Green

Write-Host "[5/6] 获取当前分支..." -ForegroundColor Green
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "当前分支: $branch" -ForegroundColor White

Write-Host "[6/6] 推送到GitHub..." -ForegroundColor Green
$pushOutput = git push -u origin $branch 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "推送失败！" -ForegroundColor Red
    Write-Host "错误信息: $pushOutput" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因:" -ForegroundColor Yellow
    Write-Host "  1. 网络连接问题" -ForegroundColor White
    Write-Host "  2. GitHub认证问题（可能需要登录）" -ForegroundColor White
    Write-Host "  3. 远程仓库权限问题" -ForegroundColor White
    Read-Host "按回车键退出"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "          上传成功！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  分支: $branch" -ForegroundColor White
Write-Host "  提交: $Message" -ForegroundColor White
Write-Host ""
Write-Host "  GitHub: https://github.com/ZY-607/Games/tree/wuxia-survivor" -ForegroundColor Blue
Write-Host ""

Read-Host "按回车键退出"
