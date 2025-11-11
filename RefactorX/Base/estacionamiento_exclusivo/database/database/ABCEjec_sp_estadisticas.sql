-- =====================================================
-- SP: APREMIOSSVN_EJECUTORES_ESTADISTICAS
-- Descripción: Obtiene estadísticas de ejecutores por vigencia y categoría
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-09
-- =====================================================

CREATE PROCEDURE APREMIOSSVN_EJECUTORES_ESTADISTICAS()
RETURNING
  VARCHAR(50) AS categoria,
  VARCHAR(100) AS descripcion,
  INTEGER AS total,
  DECIMAL(5,2) AS porcentaje,
  VARCHAR(20) AS clase;

DEFINE v_total_general INTEGER;
DEFINE v_total_vigentes INTEGER;
DEFINE v_total_no_vigentes INTEGER;
DEFINE v_total_con_oficio INTEGER;
DEFINE v_total_sin_oficio INTEGER;
DEFINE v_total_comision_alta INTEGER;

-- Obtener totales
SELECT COUNT(*) INTO v_total_general
FROM ta_15_ejecutores;

SELECT COUNT(*) INTO v_total_vigentes
FROM ta_15_ejecutores
WHERE vigencia = 'V';

SELECT COUNT(*) INTO v_total_no_vigentes
FROM ta_15_ejecutores
WHERE vigencia <> 'V' OR vigencia IS NULL;

SELECT COUNT(*) INTO v_total_con_oficio
FROM ta_15_ejecutores
WHERE oficio IS NOT NULL AND oficio <> '';

SELECT COUNT(*) INTO v_total_sin_oficio
FROM ta_15_ejecutores
WHERE oficio IS NULL OR oficio = '';

SELECT COUNT(*) INTO v_total_comision_alta
FROM ta_15_ejecutores
WHERE comision > 0;

-- Evitar división por cero
IF v_total_general = 0 THEN
  LET v_total_general = 1;
END IF;

-- Retornar estadísticas
RETURN
  'TOTAL',
  'Total de Ejecutores',
  v_total_general,
  100.00,
  'default'
WITH RESUME;

RETURN
  'VIGENTES',
  'Ejecutores Vigentes',
  v_total_vigentes,
  (v_total_vigentes::DECIMAL / v_total_general * 100),
  'V'
WITH RESUME;

RETURN
  'NO_VIGENTES',
  'Ejecutores No Vigentes',
  v_total_no_vigentes,
  (v_total_no_vigentes::DECIMAL / v_total_general * 100),
  'E'
WITH RESUME;

RETURN
  'CON_OFICIO',
  'Con Oficio Asignado',
  v_total_con_oficio,
  (v_total_con_oficio::DECIMAL / v_total_general * 100),
  'A'
WITH RESUME;

RETURN
  'SIN_OFICIO',
  'Sin Oficio',
  v_total_sin_oficio,
  (v_total_sin_oficio::DECIMAL / v_total_general * 100),
  'P'
WITH RESUME;

RETURN
  'COMISION_ALTA',
  'Con Comisión Activa',
  v_total_comision_alta,
  (v_total_comision_alta::DECIMAL / v_total_general * 100),
  'C';

END PROCEDURE;

-- =====================================================
-- Notas:
-- - Asume que existe tabla ta_15_ejecutores
-- - Campo vigencia: 'V' = vigente
-- - Campo oficio: indica asignación de oficio
-- - Campo comision: porcentaje de comisión
-- - Ejecutar con permisos de creación de procedures
-- =====================================================
