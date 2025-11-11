-- =====================================================
-- SP: apremiossvn_ejecutores_estadisticas
-- Descripción: Obtiene estadísticas de ejecutores por vigencia y categoría
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- MIGRADO DE: INFORMIX → PostgreSQL
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_ejecutores_estadisticas()
RETURNS TABLE (
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total INTEGER,
  porcentaje DECIMAL(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total_general INTEGER;
  v_total_vigentes INTEGER;
  v_total_no_vigentes INTEGER;
  v_total_con_oficio INTEGER;
  v_total_sin_oficio INTEGER;
  v_total_comision_alta INTEGER;
BEGIN
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
    v_total_general := 1;
  END IF;

  -- Retornar estadísticas
  RETURN QUERY
  SELECT
    'TOTAL'::VARCHAR(50),
    'Total de Ejecutores'::VARCHAR(100),
    v_total_general,
    100.00::DECIMAL(5,2),
    'default'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'VIGENTES'::VARCHAR(50),
    'Ejecutores Vigentes'::VARCHAR(100),
    v_total_vigentes,
    CASE
      WHEN v_total_general > 0 THEN (v_total_vigentes::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'success'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'NO_VIGENTES'::VARCHAR(50),
    'Ejecutores No Vigentes'::VARCHAR(100),
    v_total_no_vigentes,
    CASE
      WHEN v_total_general > 0 THEN (v_total_no_vigentes::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'danger'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'CON_OFICIO'::VARCHAR(50),
    'Con Oficio Asignado'::VARCHAR(100),
    v_total_con_oficio,
    CASE
      WHEN v_total_general > 0 THEN (v_total_con_oficio::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'info'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'SIN_OFICIO'::VARCHAR(50),
    'Sin Oficio'::VARCHAR(100),
    v_total_sin_oficio,
    CASE
      WHEN v_total_general > 0 THEN (v_total_sin_oficio::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'warning'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'COMISION_ALTA'::VARCHAR(50),
    'Con Comisión Activa'::VARCHAR(100),
    v_total_comision_alta,
    CASE
      WHEN v_total_general > 0 THEN (v_total_comision_alta::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'primary'::VARCHAR(20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Asume que existe tabla ta_15_ejecutores
-- - Campo vigencia: 'V' = vigente
-- - Campo oficio: indica asignación de oficio
-- - Campo comision: porcentaje de comisión
-- - Compatible con PostgreSQL 12+
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_ejecutores_estadisticas();
