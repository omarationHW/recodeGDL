-- =====================================================
-- SP: apremiossvn_apremios_estadisticas
-- Descripción: Obtiene estadísticas generales de apremios por estado y ejecutor
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_apremios_estadisticas()
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
  v_total_vencidos INTEGER;
  v_total_con_ejecutor INTEGER;
  v_total_sin_ejecutor INTEGER;
  v_importe_total DECIMAL(15,2);
BEGIN
  -- Obtener totales generales
  SELECT COUNT(*) INTO v_total_general
  FROM ta_15_apremios;

  SELECT COUNT(*) INTO v_total_vigentes
  FROM ta_15_apremios
  WHERE estado = 'V' OR estado = 'A';  -- Vigente o Activo

  SELECT COUNT(*) INTO v_total_vencidos
  FROM ta_15_apremios
  WHERE estado = 'X' OR estado = 'C' OR estado = 'B';  -- Vencido, Cancelado o Baja

  SELECT COUNT(*) INTO v_total_con_ejecutor
  FROM ta_15_apremios
  WHERE ejecutor IS NOT NULL AND ejecutor != 0;

  SELECT COUNT(*) INTO v_total_sin_ejecutor
  FROM ta_15_apremios
  WHERE ejecutor IS NULL OR ejecutor = 0;

  SELECT COALESCE(SUM(importe), 0) INTO v_importe_total
  FROM ta_15_apremios
  WHERE estado = 'V' OR estado = 'A';

  -- Evitar división por cero
  IF v_total_general = 0 THEN
    v_total_general := 1;
  END IF;

  -- Retornar estadísticas como filas
  RETURN QUERY
  SELECT
    'TOTAL'::VARCHAR(50),
    'Total de Apremios'::VARCHAR(100),
    v_total_general,
    100.00::DECIMAL(5,2),
    'default'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'VIGENTES'::VARCHAR(50),
    'Apremios Vigentes'::VARCHAR(100),
    v_total_vigentes,
    CASE
      WHEN v_total_general > 0 THEN (v_total_vigentes::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'success'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'VENCIDOS'::VARCHAR(50),
    'Apremios Vencidos/Cancelados'::VARCHAR(100),
    v_total_vencidos,
    CASE
      WHEN v_total_general > 0 THEN (v_total_vencidos::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'danger'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'CON_EJECUTOR'::VARCHAR(50),
    'Con Ejecutor Asignado'::VARCHAR(100),
    v_total_con_ejecutor,
    CASE
      WHEN v_total_general > 0 THEN (v_total_con_ejecutor::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'info'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'SIN_EJECUTOR'::VARCHAR(50),
    'Sin Ejecutor Asignado'::VARCHAR(100),
    v_total_sin_ejecutor,
    CASE
      WHEN v_total_general > 0 THEN (v_total_sin_ejecutor::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'warning'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'IMPORTE_TOTAL'::VARCHAR(50),
    'Importe Total Vigente'::VARCHAR(100),
    v_importe_total::INTEGER,  -- Convertir a entero para compatibilidad
    100.00::DECIMAL(5,2),
    'primary'::VARCHAR(20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Asume que existe tabla ta_15_apremios
-- - Campo estado: 'V'=Vigente, 'A'=Activo, 'X'=Vencido, 'C'=Cancelado, 'B'=Baja
-- - Campo ejecutor: ID del ejecutor asignado
-- - Campo importe: Monto del apremio
-- - Compatible con PostgreSQL 12+
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_apremios_estadisticas();
