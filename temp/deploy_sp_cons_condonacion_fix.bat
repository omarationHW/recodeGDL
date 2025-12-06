@echo off
echo ========================================
echo DESPLEGANDO SP CORREGIDO
echo sp_cons_condonacion_energia
echo ========================================
echo.

echo Conectando a PostgreSQL...
psql -h localhost -p 5432 -U postgres -d padron_licencias -f temp/fix_sp_cons_condonacion_energia_final.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo DESPLIEGUE EXITOSO
    echo ========================================
) else (
    echo.
    echo ========================================
    echo ERROR EN DESPLIEGUE
    echo ========================================
)

pause
