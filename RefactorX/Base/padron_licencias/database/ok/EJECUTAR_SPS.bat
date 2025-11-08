@echo off
echo ============================================
echo   DESPLIEGUE DE STORED PROCEDURES
echo   Modulo: consultausuariosfrm
echo   Base de Datos: padron_licencias
echo   Esquema: comun
echo ============================================
echo.

set PGPASSWORD=postgres
set PSQL="C:\Program Files\PostgreSQL\16\bin\psql.exe"

echo [1/6] Creando esquema comun...
%PSQL% -U postgres -d padron_licencias -c "CREATE SCHEMA IF NOT EXISTS comun;"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo crear el esquema comun
    echo Por favor verifica tu contrasena de PostgreSQL
    pause
    exit /b 1
)
echo OK - Esquema creado

echo.
echo [2/6] Ejecutando sp_catalogo_dependencias.sql...
%PSQL% -U postgres -d padron_licencias -f sp_catalogo_dependencias.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo sp_catalogo_dependencias.sql
    pause
    exit /b 1
)
echo OK

echo.
echo [3/6] Ejecutando sp_catalogo_deptos_por_dependencia.sql...
%PSQL% -U postgres -d padron_licencias -f sp_catalogo_deptos_por_dependencia.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo sp_catalogo_deptos_por_dependencia.sql
    pause
    exit /b 1
)
echo OK

echo.
echo [4/6] Ejecutando sp_consulta_usuario_por_usuario.sql...
%PSQL% -U postgres -d padron_licencias -f sp_consulta_usuario_por_usuario.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo sp_consulta_usuario_por_usuario.sql
    pause
    exit /b 1
)
echo OK

echo.
echo [5/6] Ejecutando sp_consulta_usuario_por_nombre.sql...
%PSQL% -U postgres -d padron_licencias -f sp_consulta_usuario_por_nombre.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo sp_consulta_usuario_por_nombre.sql
    pause
    exit /b 1
)
echo OK

echo.
echo [6/6] Ejecutando sp_consulta_usuario_por_dependencia_depto.sql...
%PSQL% -U postgres -d padron_licencias -f sp_consulta_usuario_por_dependencia_depto.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo sp_consulta_usuario_por_dependencia_depto.sql
    pause
    exit /b 1
)
echo OK

echo.
echo ============================================
echo   VERIFICANDO STORED PROCEDURES CREADOS
echo ============================================
%PSQL% -U postgres -d padron_licencias -c "SELECT routine_name, routine_type FROM information_schema.routines WHERE routine_schema = 'comun' AND routine_name LIKE 'sp_%%' ORDER BY routine_name;"

echo.
echo ============================================
echo   DESPLIEGUE COMPLETADO EXITOSAMENTE!
echo ============================================
echo.
echo Los siguientes SPs fueron creados en esquema comun:
echo   1. sp_catalogo_dependencias
echo   2. sp_catalogo_deptos_por_dependencia
echo   3. sp_consulta_usuario_por_usuario
echo   4. sp_consulta_usuario_por_nombre
echo   5. sp_consulta_usuario_por_dependencia_depto
echo.
echo Ahora puedes probar el componente en el navegador.
echo.
pause
