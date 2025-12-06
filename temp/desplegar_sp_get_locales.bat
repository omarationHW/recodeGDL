@echo off
echo ========================================
echo Desplegando sp_get_locales corregido
echo ========================================
echo.

set PGPASSWORD=F3rnand0
set PGHOST=192.168.20.31
set PGPORT=5432
set PGDATABASE=ingresos
set PGUSER=postgres

echo Desplegando SP...
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer) RETURNS TABLE (id_local integer, oficina smallint, num_mercado smallint, categoria smallint, seccion varchar, letra_local varchar, bloque varchar, nombre varchar, descripcion_local varchar) AS $$ BEGIN RETURN QUERY SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.letra_local, a.bloque, a.nombre, a.descripcion_local FROM public.ta_11_locales a WHERE a.id_local = p_id_local; END; $$ LANGUAGE plpgsql;"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SP desplegado exitosamente
    echo ========================================
    echo.
    echo Verificando SP...
    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "\df sp_get_locales"
) else (
    echo.
    echo ERROR: No se pudo desplegar el SP
)

pause
