-- ============================================
-- SCRIPT DE VALIDACIÓN - COMPONENTE DEPENDENCIAS
-- Módulo: padron_licencias
-- Fecha: 2025-11-20
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- VERIFICAR EXISTENCIA DE FUNCIONES
-- ============================================

SELECT
    '✓ FUNCIONES INSTALADAS' AS verificacion,
    COUNT(*) AS total_funciones
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
  AND routine_name IN (
    'sp_get_dependencias',
    'sp_get_tramite_inspecciones',
    'sp_add_inspeccion',
    'sp_delete_inspeccion',
    'sp_get_tramite_info',
    'sp_get_inspecciones_memoria',
    'sp_add_dependencia_inspeccion',
    'sp_remove_dependencia_inspeccion'
  );

-- ============================================
-- LISTAR FUNCIONES CON DETALLES
-- ============================================

SELECT
    routine_name AS nombre_funcion,
    routine_type AS tipo,
    data_type AS tipo_retorno,
    routine_definition IS NOT NULL AS tiene_definicion
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
  AND routine_name IN (
    'sp_get_dependencias',
    'sp_get_tramite_inspecciones',
    'sp_add_inspeccion',
    'sp_delete_inspeccion',
    'sp_get_tramite_info',
    'sp_get_inspecciones_memoria',
    'sp_add_dependencia_inspeccion',
    'sp_remove_dependencia_inspeccion'
  )
ORDER BY routine_name;

-- ============================================
-- VERIFICAR PARÁMETROS DE FUNCIONES
-- ============================================

SELECT
    r.routine_name AS funcion,
    p.parameter_name AS parametro,
    p.data_type AS tipo_dato,
    p.parameter_mode AS modo
FROM information_schema.routines r
LEFT JOIN information_schema.parameters p
    ON r.specific_name = p.specific_name
WHERE r.routine_schema = 'public'
  AND r.routine_type = 'FUNCTION'
  AND r.routine_name IN (
    'sp_get_dependencias',
    'sp_get_tramite_inspecciones',
    'sp_add_inspeccion',
    'sp_delete_inspeccion',
    'sp_get_tramite_info',
    'sp_get_inspecciones_memoria',
    'sp_add_dependencia_inspeccion',
    'sp_remove_dependencia_inspeccion'
  )
ORDER BY r.routine_name, p.ordinal_position;

-- ============================================
-- VERIFICAR EXISTENCIA DE TABLAS REQUERIDAS
-- ============================================

SELECT
    '✓ TABLAS REQUERIDAS' AS verificacion,
    table_name,
    CASE
        WHEN table_type = 'BASE TABLE' THEN '✓ Existe'
        ELSE '✗ No encontrada'
    END AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'c_dependencias',
    'revisiones',
    'seg_revision',
    'dependencias_inspeccion',
    'tramites'
  )
ORDER BY table_name;

-- ============================================
-- PRUEBA BÁSICA: sp_get_dependencias
-- ============================================

SELECT
    '=== PRUEBA: sp_get_dependencias ===' AS prueba;

SELECT * FROM public.sp_get_dependencias()
LIMIT 5;

-- ============================================
-- RESUMEN DE VALIDACIÓN
-- ============================================

SELECT
    'RESUMEN DE VALIDACIÓN' AS titulo,
    (SELECT COUNT(*)
     FROM information_schema.routines
     WHERE routine_schema = 'public'
       AND routine_type = 'FUNCTION'
       AND routine_name IN (
         'sp_get_dependencias',
         'sp_get_tramite_inspecciones',
         'sp_add_inspeccion',
         'sp_delete_inspeccion',
         'sp_get_tramite_info',
         'sp_get_inspecciones_memoria',
         'sp_add_dependencia_inspeccion',
         'sp_remove_dependencia_inspeccion'
       )
    ) AS funciones_instaladas,
    8 AS funciones_esperadas,
    CASE
        WHEN (SELECT COUNT(*)
              FROM information_schema.routines
              WHERE routine_schema = 'public'
                AND routine_type = 'FUNCTION'
                AND routine_name IN (
                  'sp_get_dependencias',
                  'sp_get_tramite_inspecciones',
                  'sp_add_inspeccion',
                  'sp_delete_inspeccion',
                  'sp_get_tramite_info',
                  'sp_get_inspecciones_memoria',
                  'sp_add_dependencia_inspeccion',
                  'sp_remove_dependencia_inspeccion'
                )
             ) = 8
        THEN '✓ TODAS LAS FUNCIONES INSTALADAS CORRECTAMENTE'
        ELSE '✗ FALTAN FUNCIONES POR INSTALAR'
    END AS estado;

-- ============================================
-- FIN DE VALIDACIÓN
-- ============================================
