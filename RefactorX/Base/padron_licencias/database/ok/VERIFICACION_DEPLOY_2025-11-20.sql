-- ============================================
-- SCRIPT DE VERIFICACIÓN - SESIÓN 2025-11-20
-- Módulo: padron_licencias
-- Verifica que los 40 SPs estén correctamente desplegados
-- ============================================

\echo ''
\echo '================================================================================'
\echo '           VERIFICACIÓN DE DEPLOY - SESIÓN 2025-11-20'
\echo '================================================================================'
\echo ''

-- ============================================
-- 1. VERIFICACIÓN GLOBAL
-- ============================================

\echo '▶ 1. VERIFICACIÓN GLOBAL DE SPs'
\echo ''

SELECT
    n.nspname as schema,
    COUNT(*) as total_sps,
    STRING_AGG(p.proname, ', ' ORDER BY p.proname) as sps
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('comun', 'public')
  AND p.proname LIKE 'sp_%'
GROUP BY n.nspname
ORDER BY n.nspname;

\echo ''

-- ============================================
-- 2. VERIFICACIÓN POR COMPONENTE
-- ============================================

\echo '▶ 2. VERIFICACIÓN POR COMPONENTE'
\echo ''

-- Tabla resumen
SELECT
    componente,
    sps_esperados,
    sps_encontrados,
    CASE
        WHEN sps_esperados = sps_encontrados THEN '✓ OK'
        ELSE '✗ FALTAN ' || (sps_esperados - sps_encontrados)::text
    END as estado
FROM (
    SELECT 'consultausuariosfrm' as componente, 9 as sps_esperados, COUNT(*) as sps_encontrados
    FROM pg_proc
    WHERE proname IN (
        'sp_get_all_usuarios', 'sp_buscar_usuario', 'sp_buscar_usuario_por_nombre',
        'sp_buscar_usuario_por_depto', 'sp_crear_usuario', 'sp_actualizar_usuario',
        'sp_eliminar_usuario', 'sp_get_departamentos', 'sp_get_dependencias'
    )

    UNION ALL

    SELECT 'dictamenfrm', 4, COUNT(*)
    FROM pg_proc
    WHERE proname IN (
        'sp_dictamenes_estadisticas', 'sp_dictamenes_list',
        'sp_dictamenes_create', 'sp_dictamenes_update'
    )

    UNION ALL

    SELECT 'constanciafrm', 6, COUNT(*)
    FROM pg_proc
    WHERE proname IN (
        'sp_constancias_list', 'sp_constancias_get', 'sp_constancias_create',
        'sp_constancias_update', 'sp_constancias_cancel', 'sp_constancias_get_next_folio'
    )

    UNION ALL

    SELECT 'repestado', 6, COUNT(*)
    FROM pg_proc
    WHERE proname IN (
        'sp_repestado_get_tramite_estado', 'sp_repestado_get_tramite_revisiones',
        'sp_repestado_get_revision_detalle', 'sp_repestado_get_dependencia',
        'sp_repestado_get_giro', 'sp_repestado_get_estado_completo'
    )

    UNION ALL

    SELECT 'repdoc', 4, COUNT(*)
    FROM pg_proc
    WHERE proname IN (
        'sp_repdoc_get_giros', 'sp_repdoc_get_requisitos_by_giro',
        'sp_repdoc_print_requisitos', 'sp_repdoc_print_permisos_eventuales'
    )

    UNION ALL

    SELECT 'certificacionesfrm', 7, COUNT(*)
    FROM pg_proc
    WHERE proname IN (
        'sp_certificaciones_list', 'sp_certificaciones_get', 'sp_certificaciones_create',
        'sp_certificaciones_update', 'sp_certificaciones_cancel',
        'sp_certificaciones_search', 'sp_certificaciones_print'
    )

    UNION ALL

    SELECT 'DetalleLicencia', 4, COUNT(*)
    FROM pg_proc
    WHERE proname IN (
        'sp_get_saldo_licencia', 'sp_get_detalle_licencia',
        'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia'
    )
) verificacion
ORDER BY componente;

\echo ''

-- ============================================
-- 3. DETALLE DE SPs FALTANTES (SI HAY)
-- ============================================

\echo '▶ 3. DETALLE DE SPs FALTANTES'
\echo ''

WITH sps_esperados AS (
    SELECT unnest(ARRAY[
        -- consultausuariosfrm (9)
        'sp_get_all_usuarios', 'sp_buscar_usuario', 'sp_buscar_usuario_por_nombre',
        'sp_buscar_usuario_por_depto', 'sp_crear_usuario', 'sp_actualizar_usuario',
        'sp_eliminar_usuario', 'sp_get_departamentos', 'sp_get_dependencias',
        -- dictamenfrm (4)
        'sp_dictamenes_estadisticas', 'sp_dictamenes_list',
        'sp_dictamenes_create', 'sp_dictamenes_update',
        -- constanciafrm (6)
        'sp_constancias_list', 'sp_constancias_get', 'sp_constancias_create',
        'sp_constancias_update', 'sp_constancias_cancel', 'sp_constancias_get_next_folio',
        -- repestado (6)
        'sp_repestado_get_tramite_estado', 'sp_repestado_get_tramite_revisiones',
        'sp_repestado_get_revision_detalle', 'sp_repestado_get_dependencia',
        'sp_repestado_get_giro', 'sp_repestado_get_estado_completo',
        -- repdoc (4)
        'sp_repdoc_get_giros', 'sp_repdoc_get_requisitos_by_giro',
        'sp_repdoc_print_requisitos', 'sp_repdoc_print_permisos_eventuales',
        -- certificacionesfrm (7)
        'sp_certificaciones_list', 'sp_certificaciones_get', 'sp_certificaciones_create',
        'sp_certificaciones_update', 'sp_certificaciones_cancel',
        'sp_certificaciones_search', 'sp_certificaciones_print',
        -- DetalleLicencia (4)
        'sp_get_saldo_licencia', 'sp_get_detalle_licencia',
        'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia'
    ]) as sp_name
),
sps_encontrados AS (
    SELECT proname as sp_name
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('comun', 'public')
)
SELECT
    e.sp_name as sp_faltante,
    CASE
        WHEN e.sp_name LIKE '%usuario%' THEN 'consultausuariosfrm'
        WHEN e.sp_name LIKE '%dictamen%' THEN 'dictamenfrm'
        WHEN e.sp_name LIKE '%constancia%' THEN 'constanciafrm'
        WHEN e.sp_name LIKE '%repestado%' THEN 'repestado'
        WHEN e.sp_name LIKE '%repdoc%' THEN 'repdoc'
        WHEN e.sp_name LIKE '%certificacion%' THEN 'certificacionesfrm'
        WHEN e.sp_name IN ('sp_get_saldo_licencia', 'sp_get_detalle_licencia', 'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia') THEN 'DetalleLicencia'
        ELSE 'desconocido'
    END as componente
FROM sps_esperados e
LEFT JOIN sps_encontrados f ON e.sp_name = f.sp_name
WHERE f.sp_name IS NULL;

\echo ''
\echo '  (Si no aparecen filas arriba, todos los SPs están correctamente desplegados)'
\echo ''

-- ============================================
-- 4. VERIFICACIÓN DE SCHEMAS
-- ============================================

\echo '▶ 4. VERIFICACIÓN DE SCHEMAS CORRECTOS'
\echo ''

SELECT
    n.nspname as schema,
    p.proname as sp_name,
    CASE
        -- Debería estar en 'comun'
        WHEN p.proname IN ('sp_get_all_usuarios', 'sp_buscar_usuario', 'sp_buscar_usuario_por_nombre',
                          'sp_buscar_usuario_por_depto', 'sp_crear_usuario', 'sp_actualizar_usuario',
                          'sp_eliminar_usuario', 'sp_get_departamentos', 'sp_get_dependencias',
                          'sp_dictamenes_estadisticas', 'sp_dictamenes_list', 'sp_dictamenes_create', 'sp_dictamenes_update',
                          'sp_repestado_get_tramite_estado', 'sp_repestado_get_tramite_revisiones',
                          'sp_repestado_get_revision_detalle', 'sp_repestado_get_dependencia',
                          'sp_repestado_get_giro', 'sp_repestado_get_estado_completo',
                          'sp_repdoc_get_giros', 'sp_repdoc_get_requisitos_by_giro',
                          'sp_repdoc_print_requisitos', 'sp_repdoc_print_permisos_eventuales',
                          'sp_get_saldo_licencia', 'sp_get_detalle_licencia',
                          'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia')
             AND n.nspname = 'comun' THEN '✓ OK'
        -- Debería estar en 'public'
        WHEN p.proname IN ('sp_constancias_list', 'sp_constancias_get', 'sp_constancias_create',
                          'sp_constancias_update', 'sp_constancias_cancel', 'sp_constancias_get_next_folio',
                          'sp_certificaciones_list', 'sp_certificaciones_get', 'sp_certificaciones_create',
                          'sp_certificaciones_update', 'sp_certificaciones_cancel',
                          'sp_certificaciones_search', 'sp_certificaciones_print')
             AND n.nspname = 'public' THEN '✓ OK'
        ELSE '✗ SCHEMA INCORRECTO'
    END as verificacion_schema
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname IN (
    'sp_get_all_usuarios', 'sp_buscar_usuario', 'sp_buscar_usuario_por_nombre',
    'sp_buscar_usuario_por_depto', 'sp_crear_usuario', 'sp_actualizar_usuario',
    'sp_eliminar_usuario', 'sp_get_departamentos', 'sp_get_dependencias',
    'sp_dictamenes_estadisticas', 'sp_dictamenes_list', 'sp_dictamenes_create', 'sp_dictamenes_update',
    'sp_constancias_list', 'sp_constancias_get', 'sp_constancias_create',
    'sp_constancias_update', 'sp_constancias_cancel', 'sp_constancias_get_next_folio',
    'sp_repestado_get_tramite_estado', 'sp_repestado_get_tramite_revisiones',
    'sp_repestado_get_revision_detalle', 'sp_repestado_get_dependencia',
    'sp_repestado_get_giro', 'sp_repestado_get_estado_completo',
    'sp_repdoc_get_giros', 'sp_repdoc_get_requisitos_by_giro',
    'sp_repdoc_print_requisitos', 'sp_repdoc_print_permisos_eventuales',
    'sp_certificaciones_list', 'sp_certificaciones_get', 'sp_certificaciones_create',
    'sp_certificaciones_update', 'sp_certificaciones_cancel',
    'sp_certificaciones_search', 'sp_certificaciones_print',
    'sp_get_saldo_licencia', 'sp_get_detalle_licencia',
    'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia'
)
ORDER BY n.nspname, p.proname;

\echo ''

-- ============================================
-- 5. VERIFICACIÓN DE TIPO (FUNCTION vs PROCEDURE)
-- ============================================

\echo '▶ 5. VERIFICACIÓN DE TIPO (Todos deben ser FUNCTION)'
\echo ''

SELECT
    n.nspname as schema,
    p.proname as sp_name,
    CASE p.prokind
        WHEN 'f' THEN '✓ FUNCTION'
        WHEN 'p' THEN '✗ PROCEDURE (ERROR!)'
        ELSE '? UNKNOWN'
    END as tipo
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname IN (
    'sp_get_all_usuarios', 'sp_buscar_usuario', 'sp_buscar_usuario_por_nombre',
    'sp_buscar_usuario_por_depto', 'sp_crear_usuario', 'sp_actualizar_usuario',
    'sp_eliminar_usuario', 'sp_get_departamentos', 'sp_get_dependencias',
    'sp_dictamenes_estadisticas', 'sp_dictamenes_list', 'sp_dictamenes_create', 'sp_dictamenes_update',
    'sp_constancias_list', 'sp_constancias_get', 'sp_constancias_create',
    'sp_constancias_update', 'sp_constancias_cancel', 'sp_constancias_get_next_folio',
    'sp_repestado_get_tramite_estado', 'sp_repestado_get_tramite_revisiones',
    'sp_repestado_get_revision_detalle', 'sp_repestado_get_dependencia',
    'sp_repestado_get_giro', 'sp_repestado_get_estado_completo',
    'sp_repdoc_get_giros', 'sp_repdoc_get_requisitos_by_giro',
    'sp_repdoc_print_requisitos', 'sp_repdoc_print_permisos_eventuales',
    'sp_certificaciones_list', 'sp_certificaciones_get', 'sp_certificaciones_create',
    'sp_certificaciones_update', 'sp_certificaciones_cancel',
    'sp_certificaciones_search', 'sp_certificaciones_print',
    'sp_get_saldo_licencia', 'sp_get_detalle_licencia',
    'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia'
)
ORDER BY n.nspname, p.proname;

\echo ''

-- ============================================
-- 6. VERIFICACIÓN DE EXTENSIONES
-- ============================================

\echo '▶ 6. VERIFICACIÓN DE EXTENSIONES REQUERIDAS'
\echo ''

SELECT
    extname as extension,
    extversion as version,
    '✓ Instalada' as estado
FROM pg_extension
WHERE extname = 'pgcrypto'
UNION ALL
SELECT
    'pgcrypto' as extension,
    NULL as version,
    '✗ NO INSTALADA (ERROR!)' as estado
WHERE NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto');

\echo ''

-- ============================================
-- 7. RESUMEN FINAL
-- ============================================

\echo '▶ 7. RESUMEN FINAL'
\echo ''

WITH verificacion_completa AS (
    SELECT
        40 as sps_esperados,
        COUNT(DISTINCT p.proname) as sps_encontrados
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('comun', 'public')
      AND p.proname IN (
          'sp_get_all_usuarios', 'sp_buscar_usuario', 'sp_buscar_usuario_por_nombre',
          'sp_buscar_usuario_por_depto', 'sp_crear_usuario', 'sp_actualizar_usuario',
          'sp_eliminar_usuario', 'sp_get_departamentos', 'sp_get_dependencias',
          'sp_dictamenes_estadisticas', 'sp_dictamenes_list', 'sp_dictamenes_create', 'sp_dictamenes_update',
          'sp_constancias_list', 'sp_constancias_get', 'sp_constancias_create',
          'sp_constancias_update', 'sp_constancias_cancel', 'sp_constancias_get_next_folio',
          'sp_repestado_get_tramite_estado', 'sp_repestado_get_tramite_revisiones',
          'sp_repestado_get_revision_detalle', 'sp_repestado_get_dependencia',
          'sp_repestado_get_giro', 'sp_repestado_get_estado_completo',
          'sp_repdoc_get_giros', 'sp_repdoc_get_requisitos_by_giro',
          'sp_repdoc_print_requisitos', 'sp_repdoc_print_permisos_eventuales',
          'sp_certificaciones_list', 'sp_certificaciones_get', 'sp_certificaciones_create',
          'sp_certificaciones_update', 'sp_certificaciones_cancel',
          'sp_certificaciones_search', 'sp_certificaciones_print',
          'sp_get_saldo_licencia', 'sp_get_detalle_licencia',
          'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia'
      )
)
SELECT
    sps_esperados,
    sps_encontrados,
    CASE
        WHEN sps_esperados = sps_encontrados THEN '✓ DEPLOY EXITOSO'
        ELSE '✗ DEPLOY INCOMPLETO - Faltan ' || (sps_esperados - sps_encontrados)::text || ' SPs'
    END as resultado,
    ROUND((sps_encontrados::NUMERIC / sps_esperados::NUMERIC) * 100, 1) || '%' as porcentaje_completado
FROM verificacion_completa;

\echo ''
\echo '================================================================================'
\echo '                      VERIFICACIÓN COMPLETADA'
\echo '================================================================================'
\echo ''
\echo 'Si todos los checks muestran ✓, el deploy fue exitoso.'
\echo ''
\echo 'PRÓXIMOS PASOS:'
\echo '  1. Revisar cualquier ✗ en los checks anteriores'
\echo '  2. Si todo está OK, ejecutar tests: CONSULTAUSUARIOS_PRUEBAS.sql'
\echo '  3. Probar integración con Vue/Laravel'
\echo ''
\echo '================================================================================'
\echo ''
