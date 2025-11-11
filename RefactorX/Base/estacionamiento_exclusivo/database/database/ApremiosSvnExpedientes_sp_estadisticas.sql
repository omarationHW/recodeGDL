-- =====================================================
-- SP: APREMIOSSVN_EXPEDIENTES_ESTADISTICAS
-- Descripción: Obtiene estadísticas de expedientes por fase
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-09
-- =====================================================

CREATE PROCEDURE APREMIOSSVN_EXPEDIENTES_ESTADISTICAS()
RETURNING
  VARCHAR(50) AS categoria,
  VARCHAR(100) AS descripcion,
  INTEGER AS total,
  DECIMAL(5,2) AS porcentaje,
  VARCHAR(20) AS clase;

DEFINE v_total_general INTEGER;
DEFINE v_total_requerimiento INTEGER;
DEFINE v_total_embargo INTEGER;
DEFINE v_total_remate INTEGER;
DEFINE v_total_adjudicacion INTEGER;
DEFINE v_total_concluido INTEGER;

-- Obtener totales por fase
SELECT COUNT(*) INTO v_total_general
FROM expedientes_apremios
WHERE activo = 1;

SELECT COUNT(*) INTO v_total_requerimiento
FROM expedientes_apremios
WHERE activo = 1 AND fase = 'REQUERIMIENTO';

SELECT COUNT(*) INTO v_total_embargo
FROM expedientes_apremios
WHERE activo = 1 AND fase = 'EMBARGO';

SELECT COUNT(*) INTO v_total_remate
FROM expedientes_apremios
WHERE activo = 1 AND fase = 'REMATE';

SELECT COUNT(*) INTO v_total_adjudicacion
FROM expedientes_apremios
WHERE activo = 1 AND fase = 'ADJUDICACION';

SELECT COUNT(*) INTO v_total_concluido
FROM expedientes_apremios
WHERE activo = 1 AND fase = 'CONCLUIDO';

-- Evitar división por cero
IF v_total_general = 0 THEN
  LET v_total_general = 1;
END IF;

-- Retornar estadísticas
RETURN
  'TOTAL',
  'Total de Expedientes',
  v_total_general,
  100.00,
  'default'
WITH RESUME;

RETURN
  'REQUERIMIENTO',
  'En Requerimiento',
  v_total_requerimiento,
  (v_total_requerimiento::DECIMAL / v_total_general * 100),
  'P'
WITH RESUME;

RETURN
  'EMBARGO',
  'En Embargo',
  v_total_embargo,
  (v_total_embargo::DECIMAL / v_total_general * 100),
  'E'
WITH RESUME;

RETURN
  'REMATE',
  'En Remate',
  v_total_remate,
  (v_total_remate::DECIMAL / v_total_general * 100),
  'V'
WITH RESUME;

RETURN
  'ADJUDICACION',
  'En Adjudicación',
  v_total_adjudicacion,
  (v_total_adjudicacion::DECIMAL / v_total_general * 100),
  'A'
WITH RESUME;

RETURN
  'CONCLUIDO',
  'Concluidos',
  v_total_concluido,
  (v_total_concluido::DECIMAL / v_total_general * 100),
  'C';

END PROCEDURE;

-- =====================================================
-- Notas:
-- - Asume que existe tabla expedientes_apremios
-- - Ajustar nombres de tabla/campos según esquema real
-- - Ejecutar con permisos de creación de procedures
-- =====================================================
