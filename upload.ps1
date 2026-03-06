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

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  武侠幸存者 - 一键上传脚本 v1.0" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "[1/5] 检查Git状态..." -ForegroundColor Green
$status = git status --porcelain
if ($status.Count -eq 0) {
    Write-Host "没有需要提交的更改！" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    exit 0
}

Write-Host "发现 $($status.Count) 个更改文件" -ForegroundColor White
Write-Host ""

Write-Host "[2/5] 添加所有更改..." -ForegroundColor Green
git add -A
if ($LASTEXITCODE -ne 0) {
    Write-Host "添加文件失败！" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

Write-Host "[3/5] 创建提交..." -ForegroundColor Green
if ($Message -eq "") {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "Update: $date"
}

git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    Write-Host "提交失败！" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

Write-Host "[4/5] 获取当前分支..." -ForegroundColor Green
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "当前分支: $branch" -ForegroundColor White

Write-Host "[5/5] 推送到GitHub..." -ForegroundColor Green
git push origin $branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "推送失败！请检查网络连接或GitHub认证。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  上传成功！" -ForegroundColor Green
Write-Host "  分支: $branch" -ForegroundColor White
Write-Host "  提交: $Message" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "GitHub地址: https://github.com/ZY-607/Games" -ForegroundColor Blue
Write-Host ""

Read-Host "按回车键退出"
