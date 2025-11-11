-- =====================================================
-- SP: apremiossvn_pagos_estadisticas
-- Descripción: Obtiene estadísticas de pagos por estado y tipo
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- MIGRADO DE: INFORMIX → PostgreSQL
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_pagos_estadisticas()
RETURNS TABLE (
  categoria VARCHAR(50),
  descripcion VARCHAR(100),
  total INTEGER,
  porcentaje DECIMAL(5,2),
  clase VARCHAR(20)
) AS $$
DECLARE
  v_total_general INTEGER;
  v_total_pagados INTEGER;
  v_total_pendientes INTEGER;
  v_total_parciales INTEGER;
  v_total_cancelados INTEGER;
  v_importe_total DECIMAL(15,2);
BEGIN
  -- Obtener totales de pagos (asumiendo tabla ta_15_apremios con campos de pago)
  SELECT COUNT(*) INTO v_total_general
  FROM ta_15_apremios
  WHERE estado NOT IN ('X', 'B');  -- Excluir vencidos y bajas

  SELECT COUNT(*) INTO v_total_pagados
  FROM ta_15_apremios
  WHERE estado = 'P' OR estado_pago = 'PAGADO';

  SELECT COUNT(*) INTO v_total_pendientes
  FROM ta_15_apremios
  WHERE (estado_pago IS NULL OR estado_pago = 'PENDIENTE') AND estado NOT IN ('X', 'C', 'B', 'P');

  SELECT COUNT(*) INTO v_total_parciales
  FROM ta_15_apremios
  WHERE estado_pago = 'PARCIAL';

  SELECT COUNT(*) INTO v_total_cancelados
  FROM ta_15_apremios
  WHERE estado = 'C' OR estado_pago = 'CANCELADO';

  SELECT COALESCE(SUM(importe_pagado), 0) INTO v_importe_total
  FROM ta_15_apremios
  WHERE estado_pago = 'PAGADO' OR estado = 'P';

  -- Evitar división por cero
  IF v_total_general = 0 THEN
    v_total_general := 1;
  END IF;

  -- Retornar estadísticas
  RETURN QUERY
  SELECT
    'TOTAL'::VARCHAR(50),
    'Total de Registros'::VARCHAR(100),
    v_total_general,
    100.00::DECIMAL(5,2),
    'default'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'PAGADOS'::VARCHAR(50),
    'Pagos Completados'::VARCHAR(100),
    v_total_pagados,
    CASE
      WHEN v_total_general > 0 THEN (v_total_pagados::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'success'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'PENDIENTES'::VARCHAR(50),
    'Pagos Pendientes'::VARCHAR(100),
    v_total_pendientes,
    CASE
      WHEN v_total_general > 0 THEN (v_total_pendientes::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'warning'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'PARCIALES'::VARCHAR(50),
    'Pagos Parciales'::VARCHAR(100),
    v_total_parciales,
    CASE
      WHEN v_total_general > 0 THEN (v_total_parciales::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'info'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'CANCELADOS'::VARCHAR(50),
    'Pagos Cancelados'::VARCHAR(100),
    v_total_cancelados,
    CASE
      WHEN v_total_general > 0 THEN (v_total_cancelados::DECIMAL / v_total_general * 100)
      ELSE 0.00
    END::DECIMAL(5,2),
    'danger'::VARCHAR(20);

  RETURN QUERY
  SELECT
    'IMPORTE_TOTAL'::VARCHAR(50),
    'Importe Total Pagado'::VARCHAR(100),
    v_importe_total::INTEGER,  -- Convertir a entero para compatibilidad
    100.00::DECIMAL(5,2),
    'primary'::VARCHAR(20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Asume que existe tabla ta_15_apremios con campos de pago
-- - Campo estado: 'P'=Pagado, 'V'=Vigente, 'C'=Cancelado
-- - Campo estado_pago: 'PAGADO', 'PENDIENTE', 'PARCIAL', 'CANCELADO'
-- - Campo importe_pagado: Monto pagado
-- - Compatible con PostgreSQL 12+
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_pagos_estadisticas();
