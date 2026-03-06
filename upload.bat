@echo off
chcp 65001 >nul
title Wuxia Survivor - Upload
powershell -ExecutionPolicy Bypass -File "%~dp0upload.ps1" %*
