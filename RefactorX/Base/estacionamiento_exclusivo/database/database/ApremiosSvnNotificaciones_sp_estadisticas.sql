-- =====================================================
-- SP: APREMIOSSVN_NOTIFICACIONES_ESTADISTICAS
-- Descripción: Obtiene estadísticas de notificaciones por estado y tipo
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-09
-- =====================================================

CREATE PROCEDURE APREMIOSSVN_NOTIFICACIONES_ESTADISTICAS()
RETURNING
  VARCHAR(50) AS categoria,
  VARCHAR(100) AS descripcion,
  INTEGER AS total,
  DECIMAL(5,2) AS porcentaje,
  VARCHAR(20) AS clase;

DEFINE v_total_general INTEGER;
DEFINE v_total_pendientes INTEGER;
DEFINE v_total_realizadas INTEGER;
DEFINE v_total_canceladas INTEGER;
DEFINE v_total_positivas INTEGER;
DEFINE v_total_negativas INTEGER;

-- Obtener totales por estado
SELECT COUNT(*) INTO v_total_general
FROM notificaciones
WHERE activo = 1;

SELECT COUNT(*) INTO v_total_pendientes
FROM notificaciones
WHERE activo = 1 AND estado = 'PENDIENTE';

SELECT COUNT(*) INTO v_total_realizadas
FROM notificaciones
WHERE activo = 1 AND estado = 'REALIZADA';

SELECT COUNT(*) INTO v_total_canceladas
FROM notificaciones
WHERE activo = 1 AND estado = 'CANCELADA';

-- Obtener totales por resultado
SELECT COUNT(*) INTO v_total_positivas
FROM notificaciones
WHERE activo = 1 AND resultado = 'POSITIVO';

SELECT COUNT(*) INTO v_total_negativas
FROM notificaciones
WHERE activo = 1 AND resultado = 'NEGATIVO';

-- Evitar división por cero
IF v_total_general = 0 THEN
  LET v_total_general = 1;
END IF;

-- Retornar estadísticas
RETURN
  'TOTAL',
  'Total de Notificaciones',
  v_total_general,
  100.00,
  'default'
WITH RESUME;

RETURN
  'PENDIENTES',
  'Pendientes',
  v_total_pendientes,
  (v_total_pendientes::DECIMAL / v_total_general * 100),
  'P'
WITH RESUME;

RETURN
  'REALIZADAS',
  'Realizadas',
  v_total_realizadas,
  (v_total_realizadas::DECIMAL / v_total_general * 100),
  'A'
WITH RESUME;

RETURN
  'CANCELADAS',
  'Canceladas',
  v_total_canceladas,
  (v_total_canceladas::DECIMAL / v_total_general * 100),
  'E'
WITH RESUME;

RETURN
  'POSITIVAS',
  'Resultado Positivo',
  v_total_positivas,
  (v_total_positivas::DECIMAL / v_total_general * 100),
  'V'
WITH RESUME;

RETURN
  'NEGATIVAS',
  'Resultado Negativo',
  v_total_negativas,
  (v_total_negativas::DECIMAL / v_total_general * 100),
  'C';

END PROCEDURE;

-- =====================================================
-- Notas:
-- - Asume que existe tabla notificaciones con campo activo
-- - Ajustar valores de estado según esquema real
-- - Ejecutar con permisos de creación de procedures
-- =====================================================
