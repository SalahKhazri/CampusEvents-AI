@echo off
title CampusEvents AI - Docker Cleanup

echo ========================================
echo   CampusEvents AI - Nettoyage Docker
echo ========================================
echo.

echo [1/4] Arret des conteneurs...
docker compose down 2>nul

echo [2/4] Suppression des conteneurs arretes...
docker container prune -f 2>nul

echo [3/4] Suppression des images non utilisees...
docker image prune -f 2>nul

echo [4/4] Rebuild sans cache...
docker compose build --no-cache

echo.
echo Nettoyage termine.
echo Pour lancer : docker compose up
pause
