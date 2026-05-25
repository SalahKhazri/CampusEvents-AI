@echo off
title CampusEvents AI

echo ========================================
echo   CampusEvents AI - Lancement
echo ========================================
echo.
echo [1] Flutter local (SDK installe)
echo [2] Flutter Docker (sans SDK)
echo.
choice /c 12 /n /m "Choix [1/2] : "

if errorlevel 2 goto docker
if errorlevel 1 goto local

:local
echo.
echo [1/2] Demarrage du backend FastAPI...
start "Backend CampusEvents AI" cmd /c "cd backend && call venv\Scripts\activate.bat && python run.py"

echo [2/2] Demarrage du frontend Flutter (local)...
cd frontend
flutter run
goto end

:docker
echo.
echo [1/2] Demarrage du backend FastAPI...
start "Backend CampusEvents AI" cmd /c "cd backend && call venv\Scripts\activate.bat && python run.py"

echo [2/2] Demarrage du frontend Flutter (Docker)...
echo L'application sera accessible sur http://localhost:3000
cd frontend
docker compose up
goto end

:end
pause
