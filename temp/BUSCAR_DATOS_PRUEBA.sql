-- ========================================
-- BUSCAR DATOS REALES PARA PRUEBAS
-- Ejecutar en pgAdmin - Base: padron_licencias
-- ========================================

\c padron_licencias;

-- 1. Buscar locales existentes
SELECT '========================================' as info;
SELECT '1. LOCALES DISPONIBLES' as info;
SELECT '========================================' as info;

SELECT id_local, oficina, num_mercado, categoria, seccion,
       letra_local, bloque, nombre
FROM comun.ta_11_locales
LIMIT 5;

-- 2. Buscar requerimientos (apremios)
SELECT '========================================' as info;
SELECT '2. REQUERIMIENTOS DISPONIBLES' as info;
SELECT '========================================' as info;

SELECT modulo, folio, control_otr, id_control,
       diligencia, importe_global, fecha_emision
FROM comun.ta_15_apremios
WHERE control_otr IS NOT NULL
LIMIT 10;

-- 3. BUSCAR REQUERIMIENTOS VINCULADOS A LOCALES
SELECT '========================================' as info;
SELECT '3. REQUERIMIENTOS VINCULADOS A LOCALES' as info;
SELECT '========================================' as info;

SELECT
    l.id_local,
    l.oficina,
    l.num_mercado,
    l.nombre as nombre_local,
    a.modulo,
    a.folio,
    a.control_otr,
    a.diligencia,
    a.importe_global,
    a.fecha_emision
FROM comun.ta_11_locales l
INNER JOIN comun.ta_15_apremios a ON l.id_local = a.control_otr
LIMIT 5;

-- 4. Buscar periodos asociados
SELECT '========================================' as info;
SELECT '4. PERIODOS DISPONIBLES' as info;
SELECT '========================================' as info;

SELECT control_otr, ayo, periodo, importe, recargos
FROM comun.ta_15_periodos
LIMIT 5;

-- 5. DATOS COMPLETOS PARA UNA PRUEBA REAL
SELECT '========================================' as info;
SELECT '5. DATOS COMPLETOS PARA PRUEBA' as info;
SELECT '========================================' as info;

SELECT
    '*** USAR ESTOS VALORES PARA PROBAR ***' as instruccion,
    l.id_local as "ID_LOCAL (usar en form)",
    a.modulo as "MODULO (usar en form)",
    a.folio as "FOLIO (usar en form)",
    l.nombre as "Nombre Local",
    a.importe_global as "Importe"
FROM comun.ta_11_locales l
INNER JOIN comun.ta_15_apremios a ON l.id_local = a.control_otr
LIMIT 1;
