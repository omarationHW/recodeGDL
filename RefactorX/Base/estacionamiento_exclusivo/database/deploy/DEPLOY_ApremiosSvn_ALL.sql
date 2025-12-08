-- =====================================================
-- DEPLOY: Todos los SPs para ApremiosSvn
-- Base: estacionamiento_exclusivo
-- Tablas reales: ta_15_aprem400, ta_15_historia
-- Fecha: 2025-11-26
-- =====================================================

-- =====================================================
-- 1. SP: excl_expedientes_estadisticas (NUEVO - evita conflicto)
-- =====================================================
DROP FUNCTION IF EXISTS excl_expedientes_estadisticas();
CREATE OR REPLACE FUNCTION excl_expedientes_estadisticas()
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
  v_total_pagados INTEGER;
  v_total_vencidos INTEGER;
  v_importe_total NUMERIC;
BEGIN
  -- Estadísticas desde ta_15_aprem400
  SELECT COUNT(*) INTO v_total_general FROM ta_15_aprem400;

  SELECT COUNT(*) INTO v_total_vigentes
  FROM ta_15_aprem400 WHERE vigreq = '1' OR vigreal = '1';

  SELECT COUNT(*) INTO v_total_pagados
  FROM ta_15_aprem400 WHERE fecpagr IS NOT NULL;

  SELECT COUNT(*) INTO v_total_vencidos
  FROM ta_15_aprem400 WHERE (vigreq IS NULL OR vigreq <> '1') AND (vigreal IS NULL OR vigreal <> '1');

  SELECT COALESCE(SUM(impcuo), 0) INTO v_importe_total FROM ta_15_aprem400;

  IF v_total_general = 0 THEN v_total_general := 1; END IF;

  RETURN QUERY SELECT 'TOTAL'::VARCHAR(50), 'Total Expedientes'::VARCHAR(100),
    v_total_general, 100.00::DECIMAL(5,2), 'default'::VARCHAR(20);

  RETURN QUERY SELECT 'VIGENTES'::VARCHAR(50), 'Expedientes Vigentes'::VARCHAR(100),
    v_total_vigentes, ROUND((v_total_vigentes::DECIMAL / v_total_general * 100), 2)::DECIMAL(5,2), 'success'::VARCHAR(20);

  RETURN QUERY SELECT 'PAGADOS'::VARCHAR(50), 'Con Pago Registrado'::VARCHAR(100),
    v_total_pagados, ROUND((v_total_pagados::DECIMAL / v_total_general * 100), 2)::DECIMAL(5,2), 'info'::VARCHAR(20);

  RETURN QUERY SELECT 'VENCIDOS'::VARCHAR(50), 'Vencidos/No Vigentes'::VARCHAR(100),
    v_total_vencidos, ROUND((v_total_vencidos::DECIMAL / v_total_general * 100), 2)::DECIMAL(5,2), 'warning'::VARCHAR(20);

  RETURN QUERY SELECT 'IMPORTE'::VARCHAR(50), 'Importe Total'::VARCHAR(100),
    v_importe_total::INTEGER, 100.00::DECIMAL(5,2), 'primary'::VARCHAR(20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. SP: excl_expedientes_list (NUEVO - evita conflicto)
-- =====================================================
DROP FUNCTION IF EXISTS excl_expedientes_list(VARCHAR, INTEGER, VARCHAR, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION excl_expedientes_list(
  p_q VARCHAR DEFAULT NULL,
  p_year INTEGER DEFAULT NULL,
  p_fase VARCHAR DEFAULT NULL,
  p_offset INTEGER DEFAULT 0,
  p_limit INTEGER DEFAULT 25
)
RETURNS TABLE (
  expediente VARCHAR(50),
  clave_cuenta VARCHAR(20),
  contribuyente VARCHAR(100),
  fase VARCHAR(20),
  fecha DATE,
  control INTEGER,
  folio INTEGER,
  zona SMALLINT,
  importe NUMERIC,
  vigencia VARCHAR(10),
  total_count BIGINT
) AS $$
DECLARE
  v_total BIGINT;
BEGIN
  -- Contar total
  SELECT COUNT(*) INTO v_total
  FROM ta_15_aprem400 a
  WHERE (p_q IS NULL OR p_q = '' OR
         a.control::TEXT ILIKE '%' || p_q || '%' OR
         a.folreq::TEXT ILIKE '%' || p_q || '%' OR
         a.cvelet ILIKE '%' || p_q || '%')
    AND (p_year IS NULL OR p_year = 0 OR a.axoreq = p_year)
    AND (p_fase IS NULL OR p_fase = '' OR a.dilreq = p_fase);

  RETURN QUERY
  SELECT
    (a.zonreq::VARCHAR || '-' || a.cveapl::VARCHAR || '-' || a.folreq::VARCHAR)::VARCHAR(50) AS expediente,
    (a.cvelet || a.cvenum::VARCHAR)::VARCHAR(20) AS clave_cuenta,
    COALESCE(a.grabo2, 'Sin nombre')::VARCHAR(100) AS contribuyente,
    CASE a.dilreq
      WHEN 'R' THEN 'REQUERIMIENTO'
      WHEN 'E' THEN 'EMBARGO'
      WHEN 'M' THEN 'REMATE'
      WHEN 'A' THEN 'ADJUDICACION'
      ELSE 'OTRO'
    END::VARCHAR(20) AS fase,
    a.fecreq AS fecha,
    a.control,
    a.folreq AS folio,
    a.zonreq AS zona,
    COALESCE(a.impcuo, 0) AS importe,
    CASE
      WHEN a.vigreq = '1' THEN 'Vigente'
      ELSE 'No Vigente'
    END::VARCHAR(10) AS vigencia,
    v_total
  FROM ta_15_aprem400 a
  WHERE (p_q IS NULL OR p_q = '' OR
         a.control::TEXT ILIKE '%' || p_q || '%' OR
         a.folreq::TEXT ILIKE '%' || p_q || '%' OR
         a.cvelet ILIKE '%' || p_q || '%')
    AND (p_year IS NULL OR p_year = 0 OR a.axoreq = p_year)
    AND (p_fase IS NULL OR p_fase = '' OR a.dilreq = p_fase)
  ORDER BY a.fecreq DESC, a.control DESC
  LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. SP: excl_fases_list (para ApremiosSvnFases)
-- =====================================================
DROP FUNCTION IF EXISTS excl_fases_list();
CREATE OR REPLACE FUNCTION excl_fases_list()
RETURNS TABLE (
  fase VARCHAR(20),
  descripcion VARCHAR(50),
  total INTEGER,
  porcentaje DECIMAL(5,2)
) AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total FROM ta_15_aprem400;
  IF v_total = 0 THEN v_total := 1; END IF;

  RETURN QUERY
  SELECT
    CASE dilreq
      WHEN 'R' THEN 'REQUERIMIENTO'
      WHEN 'E' THEN 'EMBARGO'
      WHEN 'M' THEN 'REMATE'
      WHEN 'A' THEN 'ADJUDICACION'
      ELSE 'OTRO'
    END::VARCHAR(20) AS fase,
    CASE dilreq
      WHEN 'R' THEN 'Requerimiento de Pago'
      WHEN 'E' THEN 'Embargo Precautorio'
      WHEN 'M' THEN 'Remate de Bienes'
      WHEN 'A' THEN 'Adjudicación'
      ELSE 'Otros Movimientos'
    END::VARCHAR(50) AS descripcion,
    COUNT(*)::INTEGER AS total,
    ROUND((COUNT(*)::DECIMAL / v_total * 100), 2)::DECIMAL(5,2) AS porcentaje
  FROM ta_15_aprem400
  GROUP BY dilreq
  ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. SP: excl_notificaciones_estadisticas
-- =====================================================
DROP FUNCTION IF EXISTS excl_notificaciones_estadisticas();
CREATE OR REPLACE FUNCTION excl_notificaciones_estadisticas()
RETURNS TABLE (
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total INTEGER,
  porcentaje DECIMAL(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total INTEGER;
  v_practicados INTEGER;
  v_pendientes INTEGER;
  v_con_citatorio INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total FROM ta_15_aprem400;
  SELECT COUNT(*) INTO v_practicados FROM ta_15_aprem400 WHERE prareq = 'P';
  SELECT COUNT(*) INTO v_pendientes FROM ta_15_aprem400 WHERE prareq IS NULL OR prareq <> 'P';
  SELECT COUNT(*) INTO v_con_citatorio FROM ta_15_aprem400 WHERE feccita IS NOT NULL;

  IF v_total = 0 THEN v_total := 1; END IF;

  RETURN QUERY SELECT 'TOTAL'::VARCHAR(50), 'Total Notificaciones'::VARCHAR(100),
    v_total, 100.00::DECIMAL(5,2), 'default'::VARCHAR(20);
  RETURN QUERY SELECT 'PRACTICADOS'::VARCHAR(50), 'Practicados'::VARCHAR(100),
    v_practicados, ROUND((v_practicados::DECIMAL / v_total * 100), 2)::DECIMAL(5,2), 'success'::VARCHAR(20);
  RETURN QUERY SELECT 'PENDIENTES'::VARCHAR(50), 'Pendientes'::VARCHAR(100),
    v_pendientes, ROUND((v_pendientes::DECIMAL / v_total * 100), 2)::DECIMAL(5,2), 'warning'::VARCHAR(20);
  RETURN QUERY SELECT 'CON_CITATORIO'::VARCHAR(50), 'Con Citatorio'::VARCHAR(100),
    v_con_citatorio, ROUND((v_con_citatorio::DECIMAL / v_total * 100), 2)::DECIMAL(5,2), 'info'::VARCHAR(20);
  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. SP: excl_notificaciones_list
-- =====================================================
DROP FUNCTION IF EXISTS excl_notificaciones_list(VARCHAR, DATE, DATE, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION excl_notificaciones_list(
  p_q VARCHAR DEFAULT NULL,
  p_desde DATE DEFAULT NULL,
  p_hasta DATE DEFAULT NULL,
  p_offset INTEGER DEFAULT 0,
  p_limit INTEGER DEFAULT 25
)
RETURNS TABLE (
  id_control INTEGER,
  folio INTEGER,
  zona SMALLINT,
  fecha_practicado DATE,
  practicado VARCHAR(10),
  fecha_citatorio DATE,
  observaciones VARCHAR(255),
  ejecutor INTEGER,
  total_count BIGINT
) AS $$
DECLARE
  v_total BIGINT;
BEGIN
  SELECT COUNT(*) INTO v_total
  FROM ta_15_aprem400 t
  WHERE (p_q IS NULL OR p_q = '' OR t.control::TEXT ILIKE '%' || p_q || '%')
    AND (p_desde IS NULL OR t.fecpra >= p_desde)
    AND (p_hasta IS NULL OR t.fecpra <= p_hasta);

  RETURN QUERY
  SELECT
    a.control AS id_control,
    a.folreq AS folio,
    a.zonreq AS zona,
    a.fecpra AS fecha_practicado,
    CASE WHEN a.prareq = 'P' THEN 'Sí' ELSE 'No' END::VARCHAR(10) AS practicado,
    a.feccita AS fecha_citatorio,
    COALESCE(a.observr, '')::VARCHAR(255) AS observaciones,
    a.ejereq AS ejecutor,
    v_total
  FROM ta_15_aprem400 a
  WHERE (p_q IS NULL OR p_q = '' OR a.control::TEXT ILIKE '%' || p_q || '%')
    AND (p_desde IS NULL OR a.fecpra >= p_desde)
    AND (p_hasta IS NULL OR a.fecpra <= p_hasta)
  ORDER BY a.fecpra DESC NULLS LAST, a.control DESC
  LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. SP: excl_pagos_estadisticas
-- =====================================================
DROP FUNCTION IF EXISTS excl_pagos_estadisticas();
CREATE OR REPLACE FUNCTION excl_pagos_estadisticas()
RETURNS TABLE (
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total INTEGER,
  porcentaje DECIMAL(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total INTEGER;
  v_con_pago INTEGER;
  v_sin_pago INTEGER;
  v_importe_pagado NUMERIC;
BEGIN
  SELECT COUNT(*) INTO v_total FROM ta_15_aprem400;
  SELECT COUNT(*) INTO v_con_pago FROM ta_15_aprem400 WHERE fecpagr IS NOT NULL;
  SELECT COUNT(*) INTO v_sin_pago FROM ta_15_aprem400 WHERE fecpagr IS NULL;
  SELECT COALESCE(SUM(impcuo), 0) INTO v_importe_pagado FROM ta_15_aprem400 WHERE fecpagr IS NOT NULL;

  IF v_total = 0 THEN v_total := 1; END IF;

  RETURN QUERY SELECT 'TOTAL'::VARCHAR(50), 'Total Registros'::VARCHAR(100),
    v_total, 100.00::DECIMAL(5,2), 'default'::VARCHAR(20);
  RETURN QUERY SELECT 'CON_PAGO'::VARCHAR(50), 'Con Pago'::VARCHAR(100),
    v_con_pago, ROUND((v_con_pago::DECIMAL / v_total * 100), 2)::DECIMAL(5,2), 'success'::VARCHAR(20);
  RETURN QUERY SELECT 'SIN_PAGO'::VARCHAR(50), 'Sin Pago'::VARCHAR(100),
    v_sin_pago, ROUND((v_sin_pago::DECIMAL / v_total * 100), 2)::DECIMAL(5,2), 'danger'::VARCHAR(20);
  RETURN QUERY SELECT 'IMPORTE'::VARCHAR(50), 'Importe Pagado Total'::VARCHAR(100),
    v_importe_pagado::INTEGER, 100.00::DECIMAL(5,2), 'primary'::VARCHAR(20);
  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. SP: excl_pagos_list
-- =====================================================
DROP FUNCTION IF EXISTS excl_pagos_list(VARCHAR, DATE, DATE, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION excl_pagos_list(
  p_q VARCHAR DEFAULT NULL,
  p_desde DATE DEFAULT NULL,
  p_hasta DATE DEFAULT NULL,
  p_offset INTEGER DEFAULT 0,
  p_limit INTEGER DEFAULT 25
)
RETURNS TABLE (
  id_control INTEGER,
  folio INTEGER,
  zona SMALLINT,
  fecha_pago DATE,
  importe NUMERIC,
  recaudadora SMALLINT,
  caja VARCHAR(10),
  operacion INTEGER,
  total_count BIGINT
) AS $$
DECLARE
  v_total BIGINT;
BEGIN
  SELECT COUNT(*) INTO v_total
  FROM ta_15_aprem400 t
  WHERE t.fecpagr IS NOT NULL
    AND (p_q IS NULL OR p_q = '' OR t.control::TEXT ILIKE '%' || p_q || '%')
    AND (p_desde IS NULL OR t.fecpagr >= p_desde)
    AND (p_hasta IS NULL OR t.fecpagr <= p_hasta);

  RETURN QUERY
  SELECT
    a.control AS id_control,
    a.folreq AS folio,
    a.zonreq AS zona,
    a.fecpagr AS fecha_pago,
    COALESCE(a.impcuo, 0) AS importe,
    a.ofnpagr AS recaudadora,
    COALESCE(a.cajpagr, '')::VARCHAR(10) AS caja,
    a.opepagr AS operacion,
    v_total
  FROM ta_15_aprem400 a
  WHERE a.fecpagr IS NOT NULL
    AND (p_q IS NULL OR p_q = '' OR a.control::TEXT ILIKE '%' || p_q || '%')
    AND (p_desde IS NULL OR a.fecpagr >= p_desde)
    AND (p_hasta IS NULL OR a.fecpagr <= p_hasta)
  ORDER BY a.fecpagr DESC, a.control DESC
  LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. SP: excl_reportes_estadisticas (general)
-- =====================================================
DROP FUNCTION IF EXISTS excl_reportes_estadisticas();
CREATE OR REPLACE FUNCTION excl_reportes_estadisticas()
RETURNS TABLE (
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total INTEGER,
  porcentaje DECIMAL(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total INTEGER;
  v_total_historia INTEGER;
  v_importe_cuotas NUMERIC;
  v_importe_gastos NUMERIC;
BEGIN
  SELECT COUNT(*) INTO v_total FROM ta_15_aprem400;
  SELECT COUNT(*) INTO v_total_historia FROM ta_15_historia;
  SELECT COALESCE(SUM(impcuo), 0) INTO v_importe_cuotas FROM ta_15_aprem400;
  SELECT COALESCE(SUM(impgas), 0) INTO v_importe_gastos FROM ta_15_aprem400;

  IF v_total = 0 THEN v_total := 1; END IF;

  RETURN QUERY SELECT 'APREMIOS'::VARCHAR(50), 'Total Apremios'::VARCHAR(100),
    v_total, 100.00::DECIMAL(5,2), 'default'::VARCHAR(20);
  RETURN QUERY SELECT 'HISTORIA'::VARCHAR(50), 'Registros Históricos'::VARCHAR(100),
    v_total_historia, 100.00::DECIMAL(5,2), 'info'::VARCHAR(20);
  RETURN QUERY SELECT 'CUOTAS'::VARCHAR(50), 'Importe en Cuotas'::VARCHAR(100),
    v_importe_cuotas::INTEGER, 100.00::DECIMAL(5,2), 'success'::VARCHAR(20);
  RETURN QUERY SELECT 'GASTOS'::VARCHAR(50), 'Importe en Gastos'::VARCHAR(100),
    v_importe_gastos::INTEGER, 100.00::DECIMAL(5,2), 'warning'::VARCHAR(20);
  RETURN;
END;
$$ LANGUAGE plpgsql;

-- Confirmación
DO $$
BEGIN
  RAISE NOTICE 'Todos los SPs de ApremiosSvn desplegados correctamente';
END $$;
