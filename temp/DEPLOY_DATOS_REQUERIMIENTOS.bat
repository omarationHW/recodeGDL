@echo off
echo ========================================
echo DESPLIEGUE: DatosRequerimientos (4 SPs)
echo ========================================
echo.

set PGPASSWORD=F3rnand0
set PGHOST=192.168.20.31
set PGPORT=5432
set PGDATABASE=ingresos
set PGUSER=postgres

echo Desplegando archivo SQL consolidado...
echo.

psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "RefactorX/Base/mercados/database/ok/45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo DESPLIEGUE EXITOSO
    echo ========================================
    echo.
    echo Verificando SPs...
    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "SELECT proname, pronargs FROM pg_proc WHERE proname IN ('sp_get_locales', 'sp_get_mercado', 'sp_get_requerimientos', 'sp_get_periodos') ORDER BY proname;"
    echo.
    echo Prueba el modulo en:
    echo http://localhost:5173/modulos/mercados/datos-requerimientos
) else (
    echo.
    echo ========================================
    echo ERROR EN DESPLIEGUE
    echo ========================================
    echo.
    echo Verifica:
    echo 1. psql esta instalado y en el PATH
    echo 2. Tienes acceso al servidor 192.168.20.31:5432
    echo 3. Las credenciales son correctas
)

pause
