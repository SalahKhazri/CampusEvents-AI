@echo off
title CampusEvents AI - Docker Dev

echo ========================================
echo   CampusEvents AI - Docker Development
echo ========================================
echo.
echo Assurez-vous que :
echo   1. Docker Desktop est lance
echo   2. Le backend FastAPI tourne sur localhost:8000
echo   3. Ollama tourne sur localhost:11434
echo.

echo [1/3] Arret des conteneurs existants...
docker compose down 2>nul

echo [2/3] Construction de l'image Flutter...
docker compose build

echo [3/3] Demarrage du conteneur Flutter...
echo.
echo L'application sera accessible sur : http://localhost:3000
echo Pour le hot reload : appuyez sur R dans cette console
echo.
docker compose up

pause
