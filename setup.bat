@echo off
echo ========================================
echo   CampusEvents AI - Installation
echo ========================================
echo.

echo [1/3] Installation des dependances backend...
cd backend
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
cd ..

echo [2/3] Installation des dependances frontend...
cd frontend
flutter pub get
cd ..

echo [3/3] Verification d'Ollama...
echo Assurez-vous d'avoir Ollama installe et le modele llama3 :
echo   ollama pull llama3
echo.

echo ========================================
echo   Installation terminee !
echo   Pour lancer le projet :
echo     run_all.bat
echo ========================================
pause
