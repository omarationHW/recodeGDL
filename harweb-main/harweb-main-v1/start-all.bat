@echo off
echo ========================================
echo  Iniciando Aplicaciones HARWEB
echo ========================================
echo.
echo Iniciando Backend (Puerto 8000) y Frontend (Puerto 5179)
echo.

REM Iniciar backend en una nueva ventana
start "HARWEB Backend - Puerto 8000" cmd /k "%~dp0start-backend.bat"

REM Esperar 2 segundos
timeout /t 2 /nobreak >nul

REM Iniciar frontend en una nueva ventana
start "HARWEB Frontend - Puerto 5179" cmd /k "%~dp0start-frontend.bat"

echo.
echo ========================================
echo  Aplicaciones iniciadas exitosamente
echo ========================================
echo.
echo Backend:  http://localhost:8000
echo Frontend: http://localhost:5179
echo.
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
