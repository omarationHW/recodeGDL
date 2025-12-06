-- ============================================================================
-- SCRIPT DE PRUEBAS: Stored Procedures - Fechas de Descuento
-- Base de Datos: mercados
-- Fecha: 2025-12-03
-- ============================================================================

\c mercados;
SET search_path TO public;

\echo ''
\echo '============================================================================'
\echo 'PRUEBAS: Stored Procedures - Fechas de Descuento'
\echo '============================================================================'
\echo ''

-- ============================================================================
-- PRUEBA 1: Verificar que los SPs existen
-- ============================================================================

\echo ''
\echo '--- PRUEBA 1: Verificar existencia de SPs ---'
\echo ''

SELECT
    routine_name as nombre_sp,
    routine_type as tipo,
    data_type as retorno
FROM information_schema.routines
WHERE (
    routine_name LIKE '%fechadescuento%'
    OR routine_name LIKE '%fechas_descuento%'
)
AND routine_schema = 'public'
ORDER BY routine_name;

\echo ''
\echo 'Esperado: 4 funciones (2 principales + 2 alias)'
\echo ''

-- ============================================================================
-- PRUEBA 2: Verificar estructura de la tabla
-- ============================================================================

\echo ''
\echo '--- PRUEBA 2: Estructura de tabla ta_11_fecha_desc ---'
\echo ''

SELECT
    column_name as columna,
    data_type as tipo,
    is_nullable as nullable
FROM information_schema.columns
WHERE table_schema = 'publico'
AND table_name = 'ta_11_fecha_desc'
ORDER BY ordinal_position;

\echo ''

-- ============================================================================
-- PRUEBA 3: Contar registros actuales
-- ============================================================================

\echo ''
\echo '--- PRUEBA 3: Registros actuales en tabla ---'
\echo ''

SELECT
    COUNT(*) as total_registros,
    MIN(mes) as mes_minimo,
    MAX(mes) as mes_maximo
FROM publico.ta_11_fecha_desc;

\echo ''
\echo 'Esperado: 12 registros (meses 1-12) o 0 si es nueva instalacion'
\echo ''

-- ============================================================================
-- PRUEBA 4: Ejecutar fechas_descuento_get_all()
-- ============================================================================

\echo ''
\echo '--- PRUEBA 4: SP fechas_descuento_get_all() ---'
\echo ''

SELECT * FROM fechas_descuento_get_all()
ORDER BY mes;

\echo ''

-- ============================================================================
-- PRUEBA 5: Ejecutar sp_fechadescuento_list() (alias)
-- ============================================================================

\echo ''
\echo '--- PRUEBA 5: SP sp_fechadescuento_list() (alias) ---'
\echo ''

SELECT COUNT(*) as total_registros FROM sp_fechadescuento_list();

\echo ''

-- ============================================================================
-- PRUEBA 6: Validación de mes inválido
-- ============================================================================

\echo ''
\echo '--- PRUEBA 6: Validacion de mes invalido (mes = 0) ---'
\echo ''

SELECT * FROM fechas_descuento_update(0, '2025-12-05', '2025-12-10', 1);

\echo ''
\echo 'Esperado: success=false, message="El mes debe estar entre 1 y 12"'
\echo ''

\echo ''
\echo '--- PRUEBA 7: Validacion de mes invalido (mes = 13) ---'
\echo ''

SELECT * FROM fechas_descuento_update(13, '2025-12-05', '2025-12-10', 1);

\echo ''
\echo 'Esperado: success=false, message="El mes debe estar entre 1 y 12"'
\echo ''

-- ============================================================================
-- PRUEBA 8: Crear/Actualizar mes 1
-- ============================================================================

\echo ''
\echo '--- PRUEBA 8: Crear o actualizar mes 1 (Enero) ---'
\echo ''

-- Guardar estado actual
\echo 'Estado ANTES de la actualizacion:'
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;

\echo ''
\echo 'Ejecutando actualizacion...'

SELECT * FROM fechas_descuento_update(
    1,
    '2025-01-05'::DATE,
    '2025-01-10'::DATE,
    1
);

\echo ''
\echo 'Estado DESPUES de la actualizacion:'
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;

\echo ''

-- ============================================================================
-- PRUEBA 9: Usar alias sp_fechadescuento_update()
-- ============================================================================

\echo ''
\echo '--- PRUEBA 9: Actualizar usando alias sp_fechadescuento_update() ---'
\echo ''

SELECT * FROM sp_fechadescuento_update(
    1,
    '2025-01-06'::DATE,
    '2025-01-11'::DATE,
    1
);

\echo ''
\echo 'Verificar cambio:'
SELECT mes, fecha_descuento, fecha_recargos FROM fechas_descuento_get_all() WHERE mes = 1;

\echo ''

-- ============================================================================
-- PRUEBA 10: Verificar join con tabla usuarios
-- ============================================================================

\echo ''
\echo '--- PRUEBA 10: Verificar join con tabla usuarios ---'
\echo ''

SELECT
    fd.mes,
    fd.fecha_descuento,
    fd.fecha_recargos,
    fd.id_usuario,
    u.usuario
FROM publico.ta_11_fecha_desc fd
LEFT JOIN public.usuarios u ON fd.id_usuario = u.id
WHERE fd.mes = 1;

\echo ''

-- ============================================================================
-- PRUEBA 11: Crear mes que no existe (si aplica)
-- ============================================================================

\echo ''
\echo '--- PRUEBA 11: Crear mes 12 (Diciembre) si no existe ---'
\echo ''

SELECT * FROM fechas_descuento_update(
    12,
    '2025-12-05'::DATE,
    '2025-12-10'::DATE,
    1
);

\echo ''
\echo 'Verificar creacion:'
SELECT * FROM fechas_descuento_get_all() WHERE mes = 12;

\echo ''

-- ============================================================================
-- PRUEBA 12: Listar todos los meses ordenados
-- ============================================================================

\echo ''
\echo '--- PRUEBA 12: Listado completo ordenado por mes ---'
\echo ''

SELECT
    mes,
    TO_CHAR(fecha_descuento, 'DD/MM/YYYY') as fecha_descuento,
    TO_CHAR(fecha_recargos, 'DD/MM/YYYY') as fecha_recargos,
    TO_CHAR(fecha_alta, 'DD/MM/YYYY HH24:MI') as fecha_alta,
    usuario
FROM fechas_descuento_get_all()
ORDER BY mes;

\echo ''

-- ============================================================================
-- RESUMEN FINAL
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo 'RESUMEN DE PRUEBAS'
\echo '============================================================================'
\echo ''

SELECT
    'Total de SPs creados' as metrica,
    COUNT(*)::TEXT as valor
FROM information_schema.routines
WHERE (
    routine_name LIKE '%fechadescuento%'
    OR routine_name LIKE '%fechas_descuento%'
)
AND routine_schema = 'public'

UNION ALL

SELECT
    'Total de registros en tabla' as metrica,
    COUNT(*)::TEXT as valor
FROM publico.ta_11_fecha_desc

UNION ALL

SELECT
    'Meses configurados' as metrica,
    COUNT(DISTINCT mes)::TEXT as valor
FROM publico.ta_11_fecha_desc

UNION ALL

SELECT
    'Mes minimo configurado' as metrica,
    MIN(mes)::TEXT as valor
FROM publico.ta_11_fecha_desc

UNION ALL

SELECT
    'Mes maximo configurado' as metrica,
    MAX(mes)::TEXT as valor
FROM publico.ta_11_fecha_desc;

\echo ''
\echo '============================================================================'
\echo 'FIN DE PRUEBAS'
\echo '============================================================================'
\echo ''
