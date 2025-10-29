@echo off
echo ========================================
echo  Iniciando Frontend Vue - Puerto 5179
echo ========================================
echo.

cd /d "%~dp0frontend-vue"

echo Frontend corriendo en: http://localhost:5179
echo Presiona Ctrl+C para detener el servidor
echo.

npm run dev
