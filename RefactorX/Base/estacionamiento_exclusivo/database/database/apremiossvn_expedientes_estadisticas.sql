-- =====================================================
-- SP: apremiossvn_expedientes_estadisticas
-- Descripción: Obtiene estadísticas de expedientes por fase
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- MIGRADO DE: INFORMIX → PostgreSQL
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_expedientes_estadisticas()
RETURNS TABLE (
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total INTEGER,
  porcentaje DECIMAL(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total_general INTEGER;
  v_total_requerimiento INTEGER;
  v_total_embargo INTEGER;
  v_total_remate INTEGER;
  v_total_adjudicacion INTEGER;
  v_total_concluido INTEGER;
BEGIN
  -- Obtener totales por fase (ajustado a ta_15_apremios con campo fase)
  SELECT COUNT(*) INTO v_total_general
  FROM ta_15_apremios
  WHERE estado NOT IN ('X', 'C', 'B');  -- Activos (no cancelados/bajas)

  SELECT COUNT(*) INTO v_total_requerimiento
  FROM ta_15_apremios
  WHERE estado NOT IN ('X', 'C', 'B') AND (fase = 'REQUERIMIENTO' OR fase IS NULL);

  SELECT COUNT(*) INTO v_total_embargo
  FROM ta_15_apremios
  WHERE estado NOT IN ('X', 'C', 'B') AND fase = 'EMBARGO';

  SELECT COUNT(*) INTO v_total_remate
  FROM ta_15_apremios
  WHERE estado NOT IN ('X', 'C', 'B') AND fase = 'REMATE';

  SELECT COUNT(*) INTO v_total_adjudicacion
  FROM ta_15_apremios
  WHERE estado NOT IN ('X', 'C', 'B') AND fase = 'ADJUDICACION';

  SELECT COUNT(*) INTO v_total_concluido
  FROM ta_15_apremios
  WHERE estado NOT IN ('X', 'C', 'B') AND fase = 'CONCLUIDO';

  -- Evitar división por cero
  IF v_total_general = 0 THEN
    v_total_general := 1;
  END IF;

  -- Retornar estadísticas
  RETURN QUERY
  SELECT
    'TOTAL'::VARCHAR(50),
    'Total de Expedientes'::VARCHAR(100),
    v_total_general,
    100.00::DECIMAL(5,2),
    'default'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'REQUERIMIENTO'::VARCHAR(50),
    'En Requerimiento'::VARCHAR(100),
    v_total_requerimiento,
    CASE
      WHEN v_total_general > 0 THEN (v_total_requerimiento::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'primary'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'EMBARGO'::VARCHAR(50),
    'En Embargo'::VARCHAR(100),
    v_total_embargo,
    CASE
      WHEN v_total_general > 0 THEN (v_total_embargo::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'warning'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'REMATE'::VARCHAR(50),
    'En Remate'::VARCHAR(100),
    v_total_remate,
    CASE
      WHEN v_total_general > 0 THEN (v_total_remate::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'info'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'ADJUDICACION'::VARCHAR(50),
    'En Adjudicación'::VARCHAR(100),
    v_total_adjudicacion,
    CASE
      WHEN v_total_general > 0 THEN (v_total_adjudicacion::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'success'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'CONCLUIDO'::VARCHAR(50),
    'Concluidos'::VARCHAR(100),
    v_total_concluido,
    CASE
      WHEN v_total_general > 0 THEN (v_total_concluido::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'secondary'::VARCHAR(20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Asume que existe tabla ta_15_apremios con campo fase
-- - Campo fase: 'REQUERIMIENTO', 'EMBARGO', 'REMATE', 'ADJUDICACION', 'CONCLUIDO'
-- - Campo estado: 'V'=Vigente, 'A'=Activo, 'X'=Vencido, 'C'=Cancelado, 'B'=Baja
-- - Compatible con PostgreSQL 12+
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_expedientes_estadisticas();
