-- =====================================================
-- SP: apremiossvn_notificaciones_estadisticas
-- Descripción: Obtiene estadísticas de notificaciones por estado
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- MIGRADO DE: INFORMIX → PostgreSQL
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_notificaciones_estadisticas()
RETURNS TABLE (
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total INTEGER,
  porcentaje DECIMAL(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total_general INTEGER;
  v_total_pendientes INTEGER;
  v_total_notificadas INTEGER;
  v_total_con_acuse INTEGER;
  v_total_sin_acuse INTEGER;
  v_total_rechazadas INTEGER;
BEGIN
  -- Obtener totales de notificaciones (asumiendo tabla ta_15_notificaciones o similar)
  SELECT COUNT(*) INTO v_total_general
  FROM ta_15_apremios
  WHERE fecha_notificacion IS NOT NULL OR estado_notificacion IS NOT NULL;

  SELECT COUNT(*) INTO v_total_pendientes
  FROM ta_15_apremios
  WHERE estado_notificacion = 'PENDIENTE' OR (fecha_notificacion IS NULL AND estado NOT IN ('X', 'C', 'B'));

  SELECT COUNT(*) INTO v_total_notificadas
  FROM ta_15_apremios
  WHERE fecha_notificacion IS NOT NULL;

  SELECT COUNT(*) INTO v_total_con_acuse
  FROM ta_15_apremios
  WHERE fecha_acuse IS NOT NULL;

  SELECT COUNT(*) INTO v_total_sin_acuse
  FROM ta_15_apremios
  WHERE fecha_notificacion IS NOT NULL AND fecha_acuse IS NULL;

  SELECT COUNT(*) INTO v_total_rechazadas
  FROM ta_15_apremios
  WHERE estado_notificacion = 'RECHAZADA';

  -- Evitar división por cero
  IF v_total_general = 0 THEN
    v_total_general := 1;
  END IF;

  -- Retornar estadísticas
  RETURN QUERY
  SELECT
    'TOTAL'::VARCHAR(50),
    'Total de Notificaciones'::VARCHAR(100),
    v_total_general,
    100.00::DECIMAL(5,2),
    'default'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'PENDIENTES'::VARCHAR(50),
    'Notificaciones Pendientes'::VARCHAR(100),
    v_total_pendientes,
    CASE
      WHEN v_total_general > 0 THEN (v_total_pendientes::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'warning'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'NOTIFICADAS'::VARCHAR(50),
    'Notificaciones Realizadas'::VARCHAR(100),
    v_total_notificadas,
    CASE
      WHEN v_total_general > 0 THEN (v_total_notificadas::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'success'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'CON_ACUSE'::VARCHAR(50),
    'Con Acuse de Recibo'::VARCHAR(100),
    v_total_con_acuse,
    CASE
      WHEN v_total_general > 0 THEN (v_total_con_acuse::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'info'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'SIN_ACUSE'::VARCHAR(50),
    'Sin Acuse de Recibo'::VARCHAR(100),
    v_total_sin_acuse,
    CASE
      WHEN v_total_general > 0 THEN (v_total_sin_acuse::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'secondary'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'RECHAZADAS'::VARCHAR(50),
    'Notificaciones Rechazadas'::VARCHAR(100),
    v_total_rechazadas,
    CASE
      WHEN v_total_general > 0 THEN (v_total_rechazadas::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'danger'::VARCHAR(20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Asume que existe tabla ta_15_apremios con campos de notificación
-- - Campo fecha_notificacion: Fecha de notificación
-- - Campo fecha_acuse: Fecha de acuse de recibo
-- - Campo estado_notificacion: 'PENDIENTE', 'NOTIFICADA', 'RECHAZADA'
-- - Compatible con PostgreSQL 12+
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_notificaciones_estadisticas();
