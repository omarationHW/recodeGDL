@echo off
echo Desplegando fix para sp_get_mercados_by_recaudadora...
echo.

"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d padron_licencias -f "%~dp0fix_sp_get_mercados_by_recaudadora.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Despliegue exitoso
    echo.
    echo Verificando versiones del SP...
    "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d padron_licencias -c "SELECT p.proname, pg_catalog.pg_get_function_arguments(p.oid) AS arguments FROM pg_catalog.pg_proc p WHERE p.proname = 'sp_get_mercados_by_recaudadora';"
) else (
    echo.
    echo ❌ Error en el despliegue
)

pause
