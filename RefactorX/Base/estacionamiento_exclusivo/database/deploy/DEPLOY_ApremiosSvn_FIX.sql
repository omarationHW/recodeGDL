-- =====================================================
-- FIX: SPs para ApremiosSvn - Usando tablas reales
-- Base: estacionamiento_exclusivo
-- Tablas: ta_15_aprem400, ta_15_historia
-- Fecha: 2025-11-26
-- =====================================================

-- 1. SP de estadísticas de apremios (usando ta_15_aprem400)
DROP FUNCTION IF EXISTS apremiossvn_apremios_estadisticas();
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
  -- Obtener totales generales de ta_15_aprem400
  SELECT COUNT(*) INTO v_total_general
  FROM ta_15_aprem400;

  -- Vigentes: vigreq = '1' o vigreal = '1'
  SELECT COUNT(*) INTO v_total_vigentes
  FROM ta_15_aprem400
  WHERE vigreq = '1' OR vigreal = '1';

  -- Vencidos/No vigentes
  SELECT COUNT(*) INTO v_total_vencidos
  FROM ta_15_aprem400
  WHERE (vigreq IS NULL OR vigreq <> '1') AND (vigreal IS NULL OR vigreal <> '1');

  -- Con ejecutor (ejereq > 0)
  SELECT COUNT(*) INTO v_total_con_ejecutor
  FROM ta_15_aprem400
  WHERE ejereq IS NOT NULL AND ejereq > 0;

  -- Sin ejecutor
  SELECT COUNT(*) INTO v_total_sin_ejecutor
  FROM ta_15_aprem400
  WHERE ejereq IS NULL OR ejereq = 0;

  -- Importe total de cuotas vigentes
  SELECT COALESCE(SUM(impcuo), 0) INTO v_importe_total
  FROM ta_15_aprem400
  WHERE vigreq = '1' OR vigreal = '1';

  -- Evitar división por cero
  IF v_total_general = 0 THEN
    v_total_general := 1;
  END IF;

  -- Retornar estadísticas
  RETURN QUERY SELECT 'TOTAL'::VARCHAR(50), 'Total de Apremios'::VARCHAR(100),
    v_total_general, 100.00::DECIMAL(5,2), 'default'::VARCHAR(20);

  RETURN QUERY SELECT 'VIGENTES'::VARCHAR(50), 'Apremios Vigentes'::VARCHAR(100),
    v_total_vigentes,
    ROUND((v_total_vigentes::DECIMAL / v_total_general * 100), 2)::DECIMAL(5,2),
    'success'::VARCHAR(20);

  RETURN QUERY SELECT 'VENCIDOS'::VARCHAR(50), 'Apremios Vencidos/No Vigentes'::VARCHAR(100),
    v_total_vencidos,
    ROUND((v_total_vencidos::DECIMAL / v_total_general * 100), 2)::DECIMAL(5,2),
    'danger'::VARCHAR(20);

  RETURN QUERY SELECT 'CON_EJECUTOR'::VARCHAR(50), 'Con Ejecutor Asignado'::VARCHAR(100),
    v_total_con_ejecutor,
    ROUND((v_total_con_ejecutor::DECIMAL / v_total_general * 100), 2)::DECIMAL(5,2),
    'info'::VARCHAR(20);

  RETURN QUERY SELECT 'SIN_EJECUTOR'::VARCHAR(50), 'Sin Ejecutor Asignado'::VARCHAR(100),
    v_total_sin_ejecutor,
    ROUND((v_total_sin_ejecutor::DECIMAL / v_total_general * 100), 2)::DECIMAL(5,2),
    'warning'::VARCHAR(20);

  RETURN QUERY SELECT 'IMPORTE_TOTAL'::VARCHAR(50), 'Importe Total Vigente'::VARCHAR(100),
    v_importe_total::INTEGER, 100.00::DECIMAL(5,2), 'primary'::VARCHAR(20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- 2. SP de listado de actuaciones (usando ta_15_historia para historial de movimientos)
DROP FUNCTION IF EXISTS sp_actuaciones_list(VARCHAR, DATE, DATE);
CREATE OR REPLACE FUNCTION sp_actuaciones_list(
  p_expediente VARCHAR(50) DEFAULT NULL,
  p_desde DATE DEFAULT NULL,
  p_hasta DATE DEFAULT NULL
)
RETURNS TABLE (
  id_actuacion INTEGER,
  control INTEGER,
  folio INTEGER,
  zona SMALLINT,
  modulo SMALLINT,
  fecha DATE,
  diligencia VARCHAR(10),
  importe_global NUMERIC,
  importe_multa NUMERIC,
  importe_recargo NUMERIC,
  importe_gastos NUMERIC,
  ejecutor SMALLINT,
  clave_mov VARCHAR(10),
  observaciones VARCHAR(255),
  vigencia VARCHAR(10),
  fecha_actualiz DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    h.id_control AS id_actuacion,
    h.control,
    h.folio,
    h.zona,
    h.modulo,
    h.fecha_emision AS fecha,
    h.diligencia::VARCHAR(10),
    h.importe_global,
    h.importe_multa,
    h.importe_recargo,
    h.importe_gastos,
    h.ejecutor,
    h.clave_mov::VARCHAR(10),
    h.observaciones::VARCHAR(255),
    h.vigencia::VARCHAR(10),
    h.fecha_actualiz
  FROM ta_15_historia h
  WHERE 1=1
    AND (p_expediente IS NULL OR h.control::TEXT ILIKE '%' || p_expediente || '%'
         OR h.folio::TEXT ILIKE '%' || p_expediente || '%')
    AND (p_desde IS NULL OR h.fecha_emision >= p_desde)
    AND (p_hasta IS NULL OR h.fecha_emision <= p_hasta)
  ORDER BY h.fecha_emision DESC, h.id_control DESC
  LIMIT 500;
END;
$$ LANGUAGE plpgsql;

-- Confirmación
DO $$
BEGIN
  RAISE NOTICE 'SPs para ApremiosSvn actualizados exitosamente';
END $$;
