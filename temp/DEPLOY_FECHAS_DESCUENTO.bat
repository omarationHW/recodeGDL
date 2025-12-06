@echo off
echo ============================================================================
echo DESPLIEGUE: Stored Procedures - Fechas de Descuento
echo Base de Datos: mercados
echo Host: 192.168.6.146:5432
echo ============================================================================
echo.

REM Configurar password
set PGPASSWORD=FF)-BQk2

REM Ruta al archivo SQL
set SQL_FILE=C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\fechas_descuento_all_sps_FINAL.sql

echo [1/3] Verificando archivo SQL...
if not exist "%SQL_FILE%" (
    echo ERROR: No se encuentra el archivo SQL
    echo Ruta: %SQL_FILE%
    pause
    exit /b 1
)
echo OK - Archivo encontrado

echo.
echo [2/3] Desplegando Stored Procedures...
echo.

psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f "%SQL_FILE%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Fallo el despliegue
    echo.
    echo ALTERNATIVA: Ejecutar manualmente en DBeaver/pgAdmin
    echo 1. Abrir DBeaver o pgAdmin
    echo 2. Conectar a: 192.168.6.146:5432, base: mercados
    echo 3. Abrir archivo: %SQL_FILE%
    echo 4. Ejecutar el script completo
    pause
    exit /b 1
)

echo.
echo [3/3] Verificando creacion de SPs...
echo.

psql -h 192.168.6.146 -p 5432 -U refact -d mercados -c "SELECT routine_name, routine_type FROM information_schema.routines WHERE routine_name LIKE '%%fechadescuento%%' OR routine_name LIKE '%%fechas_descuento%%' ORDER BY routine_name;"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo verificar
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo DESPLIEGUE COMPLETADO EXITOSAMENTE
echo ============================================================================
echo.
echo SPs creados:
echo   1. fechas_descuento_get_all()
echo   2. fechas_descuento_update()
echo   3. sp_fechadescuento_list() - Alias
echo   4. sp_fechadescuento_update() - Alias
echo.
echo Para probar:
echo   psql -h 192.168.6.146 -p 5432 -U refact -d mercados -c "SELECT * FROM fechas_descuento_get_all();"
echo.
pause
