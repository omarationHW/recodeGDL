@echo off
echo ================================================================
echo INSTALACION DE STORED PROCEDURES - LOTE 1
echo Modulo: Estacionamiento Exclusivo
echo ================================================================
echo.

set PGPASSWORD=FF)-BQk2
set PSQL_PATH=C:\Program Files\PostgreSQL\16\bin\psql.exe
set HOST=192.168.6.146
set USER=refact
set DB_PRINCIPAL=estacionamiento_exclusivo
set DB_LICENCIAS=padron_licencias

echo [1/2] Instalando SPs en estacionamiento_exclusivo...
"%PSQL_PATH%" -h %HOST% -U %USER% -d %DB_PRINCIPAL% -f LOTE1_STORED_PROCEDURES.sql

if %ERRORLEVEL% EQU 0 (
    echo [OK] SPs instalados correctamente en estacionamiento_exclusivo
) else (
    echo [ERROR] Fallo al instalar SPs en estacionamiento_exclusivo
    pause
    exit /b 1
)

echo.
echo [2/2] Verificando SPs instalados...
"%PSQL_PATH%" -h %HOST% -U %USER% -d %DB_PRINCIPAL% -c "SELECT routine_name FROM information_schema.routines WHERE routine_schema='public' AND routine_name LIKE 'sp_%' ORDER BY routine_name;"

echo.
echo ================================================================
echo INSTALACION COMPLETADA
echo ================================================================
echo.
pause
