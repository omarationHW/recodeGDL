@echo off
echo ================================================
echo   Iniciando Backend y Frontend
echo ================================================
echo.

echo [Backend] Iniciando Laravel en http://127.0.0.1:8100...
start "Backend Laravel" cmd /k "cd /d %~dp0RefactorX\BackEnd && c:\xampp\php\php.exe artisan serve --port=8100"

echo [Frontend] Iniciando Vue/Vite en http://localhost:3000...
start "Frontend Vue" cmd /k "cd /d %~dp0RefactorX\FrontEnd && npm run dev"

echo.
echo ================================================
echo   Servidores iniciados exitosamente
echo ================================================
echo   Backend:  http://127.0.0.1:8100
echo   Frontend: http://localhost:3000
echo ================================================
echo.
echo Presiona cualquier tecla para salir...
pause >nul
