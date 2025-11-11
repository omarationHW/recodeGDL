-- =====================================================
-- SP: APREMIOSSVN_APREMIOS_ESTADISTICAS
-- Descripción: Obtiene estadísticas de apremios por vigencia y zona
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-09
-- =====================================================

CREATE PROCEDURE APREMIOSSVN_APREMIOS_ESTADISTICAS()
RETURNING
  VARCHAR(50) AS categoria,
  VARCHAR(100) AS descripcion,
  INTEGER AS total,
  DECIMAL(5,2) AS porcentaje,
  VARCHAR(20) AS clase;

DEFINE v_total_general INTEGER;
DEFINE v_total_vigentes INTEGER;
DEFINE v_total_vencidos INTEGER;
DEFINE v_total_con_ejecutor INTEGER;
DEFINE v_total_sin_ejecutor INTEGER;
DEFINE v_suma_importes DECIMAL(15,2);

-- Obtener totales
SELECT COUNT(*) INTO v_total_general
FROM ta_15_apremios;

SELECT COUNT(*) INTO v_total_vigentes
FROM ta_15_apremios
WHERE vigencia = 'V';

SELECT COUNT(*) INTO v_total_vencidos
FROM ta_15_apremios
WHERE vigencia <> 'V' OR vigencia IS NULL;

SELECT COUNT(*) INTO v_total_con_ejecutor
FROM ta_15_apremios
WHERE ejecutor IS NOT NULL AND ejecutor > 0;

SELECT COUNT(*) INTO v_total_sin_ejecutor
FROM ta_15_apremios
WHERE ejecutor IS NULL OR ejecutor = 0;

SELECT COALESCE(SUM(importe_global), 0) INTO v_suma_importes
FROM ta_15_apremios
WHERE vigencia = 'V';

-- Evitar división por cero
IF v_total_general = 0 THEN
  LET v_total_general = 1;
END IF;

-- Retornar estadísticas
RETURN
  'TOTAL',
  'Total de Apremios',
  v_total_general,
  100.00,
  'default'
WITH RESUME;

RETURN
  'VIGENTES',
  'Apremios Vigentes',
  v_total_vigentes,
  (v_total_vigentes::DECIMAL / v_total_general * 100),
  'V'
WITH RESUME;

RETURN
  'VENCIDOS',
  'Apremios Vencidos',
  v_total_vencidos,
  (v_total_vencidos::DECIMAL / v_total_general * 100),
  'E'
WITH RESUME;

RETURN
  'CON_EJECUTOR',
  'Con Ejecutor Asignado',
  v_total_con_ejecutor,
  (v_total_con_ejecutor::DECIMAL / v_total_general * 100),
  'A'
WITH RESUME;

RETURN
  'SIN_EJECUTOR',
  'Sin Ejecutor',
  v_total_sin_ejecutor,
  (v_total_sin_ejecutor::DECIMAL / v_total_general * 100),
  'P'
WITH RESUME;

RETURN
  'IMPORTE_TOTAL',
  'Importe Total Vigente',
  v_suma_importes::INTEGER,
  0.00,
  'C';

END PROCEDURE;

-- =====================================================
-- Notas:
-- - Asume que existe tabla ta_15_apremios
-- - Campo vigencia: 'V' = vigente
-- - Campo ejecutor: clave de ejecutor asignado
-- - Campo importe_global: importe del apremio
-- - El importe se muestra como entero
-- - Ejecutar con permisos de creación de procedures
-- =====================================================
