@echo off
REM Script para ejecutar la corrección del SP sp_padron_global
REM =========================================================

echo.
echo =========================================
echo CORRIGIENDO SP sp_padron_global
echo =========================================
echo.

REM Configurar variables de conexión
set PGHOST=192.168.6.146
set PGPORT=5432
set PGDATABASE=mercados
set PGUSER=refact
set PGPASSWORD=FF)-BQk2

REM Ejecutar el script SQL
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f fix_sp_padron_global.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =========================================
    echo CORRECCIÓN COMPLETADA EXITOSAMENTE
    echo =========================================
) else (
    echo.
    echo =========================================
    echo ERROR EN LA CORRECCIÓN
    echo =========================================
    echo Codigo de error: %ERRORLEVEL%
)

echo.
pause
