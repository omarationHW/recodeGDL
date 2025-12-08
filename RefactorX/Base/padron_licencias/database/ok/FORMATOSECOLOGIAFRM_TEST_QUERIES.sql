-- ============================================
-- QUERIES DE PRUEBA - formatosEcologiafrm
-- Componente: formatosEcologiafrm
-- Fecha: 2025-11-20
-- ============================================
-- INSTRUCCIONES:
-- Ejecutar estas queries después de desplegar los stored procedures
-- para verificar que funcionan correctamente.
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- PRUEBA 1: sp_get_tramite_by_id
-- ============================================
\echo '>>> PRUEBA 1: sp_get_tramite_by_id'

-- Prueba con ID válido (ajustar según datos reales)
SELECT * FROM sp_get_tramite_by_id(1);

-- Prueba de campos calculados específicamente
SELECT
    id_tramite,
    folio,
    propietario,
    primer_ap,
    segundo_ap,
    propietarionvo AS "Nombre Completo Calculado",
    ubicacion,
    numext_ubic,
    cp,
    domcompleto AS "Domicilio Completo Calculado"
FROM sp_get_tramite_by_id(1);

-- Prueba con parámetro NULL (debe fallar con excepción)
-- SELECT * FROM sp_get_tramite_by_id(NULL);

-- Prueba con ID inexistente (debe fallar con excepción)
-- SELECT * FROM sp_get_tramite_by_id(999999);

-- ============================================
-- PRUEBA 2: sp_get_tramites_by_fecha
-- ============================================
\echo ''
\echo '>>> PRUEBA 2: sp_get_tramites_by_fecha'

-- Prueba con fecha actual
SELECT
    id_tramite,
    folio,
    tipo_tramite,
    propietarionvo AS "Propietario",
    domcompleto AS "Domicilio",
    feccap AS "Fecha Captura",
    estatus
FROM sp_get_tramites_by_fecha(CURRENT_DATE);

-- Prueba con fecha específica (ajustar según datos reales)
SELECT COUNT(*) AS total_tramites
FROM sp_get_tramites_by_fecha('2025-11-01');

-- Prueba con fecha pasada
SELECT
    id_tramite,
    folio,
    propietarionvo,
    estatus
FROM sp_get_tramites_by_fecha('2025-01-01')
LIMIT 10;

-- Prueba con parámetro NULL (debe fallar con excepción)
-- SELECT * FROM sp_get_tramites_by_fecha(NULL);

-- ============================================
-- PRUEBA 3: sp_get_cruce_calles_by_tramite
-- ============================================
\echo ''
\echo '>>> PRUEBA 3: sp_get_cruce_calles_by_tramite'

-- Prueba con ID válido que tenga cruces (ajustar según datos reales)
SELECT * FROM sp_get_cruce_calles_by_tramite(1);

-- Prueba mostrando información completa
SELECT
    calle AS "Calle Principal",
    calle_1 AS "Calle Secundaria"
FROM sp_get_cruce_calles_by_tramite(1);

-- Prueba con parámetro NULL (debe fallar con excepción)
-- SELECT * FROM sp_get_cruce_calles_by_tramite(NULL);

-- Prueba con ID inexistente (debe fallar con excepción)
-- SELECT * FROM sp_get_cruce_calles_by_tramite(999999);

-- ============================================
-- PRUEBAS INTEGRADAS
-- ============================================
\echo ''
\echo '>>> PRUEBAS INTEGRADAS'

-- Prueba: Obtener trámite con sus cruces de calles
SELECT
    t.id_tramite,
    t.folio,
    t.propietarionvo AS propietario,
    t.domcompleto AS domicilio,
    t.estatus,
    c.calle AS calle_principal,
    c.calle_1 AS calle_secundaria
FROM sp_get_tramite_by_id(1) t
LEFT JOIN sp_get_cruce_calles_by_tramite(1) c ON true;

-- Prueba: Trámites del día con conteo de cruces
SELECT
    t.id_tramite,
    t.folio,
    t.propietarionvo,
    t.estatus,
    (SELECT COUNT(*) FROM sp_get_cruce_calles_by_tramite(t.id_tramite)) AS num_cruces
FROM sp_get_tramites_by_fecha(CURRENT_DATE) t
LIMIT 10;

-- ============================================
-- VERIFICACIÓN DE METADATOS
-- ============================================
\echo ''
\echo '>>> VERIFICACIÓN DE METADATOS'

-- Verificar que las funciones existen
SELECT
    p.proname AS nombre_funcion,
    pg_catalog.pg_get_function_arguments(p.oid) AS parametros,
    pg_catalog.obj_description(p.oid, 'pg_proc') AS descripcion
FROM pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname IN (
    'sp_get_tramite_by_id',
    'sp_get_tramites_by_fecha',
    'sp_get_cruce_calles_by_tramite'
)
AND n.nspname = 'public'
ORDER BY p.proname;

-- ============================================
-- PRUEBAS DE RENDIMIENTO (OPCIONAL)
-- ============================================
\echo ''
\echo '>>> PRUEBAS DE RENDIMIENTO'

-- Tiempo de ejecución para consulta individual
\timing on
SELECT * FROM sp_get_tramite_by_id(1);
\timing off

-- Tiempo de ejecución para consulta por fecha
\timing on
SELECT COUNT(*) FROM sp_get_tramites_by_fecha(CURRENT_DATE);
\timing off

-- ============================================
-- FIN DE PRUEBAS
-- ============================================
\echo ''
\echo '>>> FIN DE PRUEBAS - formatosEcologiafrm'
\echo ''
\echo 'NOTA: Ajustar los IDs y fechas según los datos reales en la base de datos'
\echo 'Las pruebas comentadas (--) generan excepciones intencionalmente'
