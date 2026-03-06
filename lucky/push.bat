@echo off
chcp 65001 > nul
echo ==============================================
echo          GitHub 一键推送脚本 (ZY-607)
echo ==============================================
echo.

:: 检查是否是Git仓库
git rev-parse --is-inside-work-tree > nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：当前目录不是Git仓库！
    pause
    exit /b 1
)

:: 拉取最新代码（避免冲突）
echo 📥 正在拉取远程最新代码...
git pull origin main
if errorlevel 1 (
    echo ⚠️  拉取代码时可能有冲突，请先手动解决！
    pause
    exit /b 1
)

:: 提示输入更新说明
set /p commit_msg=请输入本次更新说明（例如：修复XXbug/新增XX功能）：
if "%commit_msg%"=="" (
    set commit_msg=默认更新：%date% %time%
)

:: 添加所有文件
echo 📤 正在添加所有修改的文件...
git add .

:: 提交代码
echo 📝 正在提交代码...
git commit -m "%commit_msg%"
if errorlevel 1 (
    echo ⚠️  没有需要提交的修改！
    pause
    exit /b 0
)

:: 推送代码到GitHub
echo 🚀 正在推送到GitHub仓库...
git push origin main

if errorlevel 0 (
    echo.
    echo ✅ 推送成功！
    echo 🔗 仓库地址：https://github.com/ZY-607/Lucky-King
) else (
    echo.
    echo ❌ 推送失败！请检查网络或凭证是否正确。
)

echo.
pause