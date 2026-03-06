@echo off
chcp 65001 >nul
title 武侠幸存者 - 一键上传
powershell -ExecutionPolicy Bypass -File "%~dp0upload.ps1" %*
