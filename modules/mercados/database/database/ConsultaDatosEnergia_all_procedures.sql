-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsultaDatosEnergia
-- Generado: 2025-08-26 23:25:04
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_get_energia_by_local
-- Tipo: Catalog
-- Descripción: Obtiene los datos de energía eléctrica para un local dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_energia_by_local(p_id_local INT)
RETURNS TABLE (
  id_energia INT,
  id_local INT,
  cve_consumo VARCHAR(1),
  local_adicional VARCHAR(50),
  cantidad NUMERIC,
  vigencia VARCHAR(1),
  fecha_alta DATE,
  fecha_baja DATE,
  fecha_modificacion TIMESTAMP,
  id_usuario INT,
  usuario VARCHAR(50)
) AS $$
BEGIN
  RETURN QUERY
    SELECT e.id_energia, e.id_local, e.cve_consumo, e.local_adicional, e.cantidad, e.vigencia, e.fecha_alta, e.fecha_baja, e.fecha_modificacion, e.id_usuario, u.usuario
    FROM ta_11_energia e
    LEFT JOIN ta_12_passwords u ON e.id_usuario = u.id_usuario
    WHERE e.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_get_requerimientos_energia
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos de energía para un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos_energia(p_id_local INT)
RETURNS TABLE (
  id_control INT,
  modulo SMALLINT,
  control_otr INT,
  folio INT,
  diligencia VARCHAR(1),
  importe_global NUMERIC,
  importe_multa NUMERIC,
  importe_gastos NUMERIC,
  fecha_emision DATE,
  clave_practicado VARCHAR(1),
  vigencia VARCHAR(1)
) AS $$
BEGIN
  RETURN QUERY
    SELECT r.id_control, r.modulo, r.control_otr, r.folio, r.diligencia, r.importe_global, r.importe_multa, r.importe_gastos, r.fecha_emision, r.clave_practicado, r.vigencia
    FROM ta_15_apremios r
    WHERE r.modulo = 33 AND r.control_otr = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_get_adeudos_energia
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos de energía eléctrica para un local, incluyendo cálculo de recargos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_energia(p_id_local INT)
RETURNS TABLE (
  axo SMALLINT,
  periodo SMALLINT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
DECLARE
  r RECORD;
  recargo NUMERIC;
BEGIN
  FOR r IN SELECT a.axo, a.periodo, a.importe, a.id_energia FROM ta_11_adeudo_energ a
           JOIN ta_11_energia e ON a.id_energia = e.id_energia
           WHERE e.id_local = p_id_local
           ORDER BY a.axo, a.periodo
  LOOP
    -- Cálculo de recargos (simplificado, debe ajustarse según reglas reales)
    SELECT COALESCE(SUM(porcentaje_mes),0) INTO recargo
      FROM ta_12_recargos
      WHERE axo = r.axo AND mes >= r.periodo;
    RETURN NEXT (r.axo, r.periodo, r.importe, (r.importe * recargo / 100));
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_get_recargos_energia
-- Tipo: Catalog
-- Descripción: Obtiene el porcentaje de recargos para un año y mes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recargos_energia(p_axo SMALLINT, p_mes SMALLINT)
RETURNS TABLE (
  porcentaje NUMERIC
) AS $$
BEGIN
  RETURN QUERY
    SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE axo = p_axo AND mes >= p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_get_dia_vencimiento
-- Tipo: Catalog
-- Descripción: Obtiene el día de vencimiento para recargos de un mes dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dia_vencimiento(p_mes SMALLINT)
RETURNS TABLE (
  dia SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha_limite)::SMALLINT FROM ta_12_diaslimite WHERE EXTRACT(MONTH FROM fecha_limite) = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_get_pagos_energia
-- Tipo: Catalog
-- Descripción: Obtiene los pagos de energía para un id_energia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_energia(p_id_energia INT)
RETURNS TABLE (
  id_pago_energia INT,
  id_energia INT,
  axo SMALLINT,
  periodo SMALLINT,
  fecha_pago DATE,
  importe_pago NUMERIC,
  usuario VARCHAR(50)
) AS $$
BEGIN
  RETURN QUERY
    SELECT p.id_pago_energia, p.id_energia, p.axo, p.periodo, p.fecha_pago, p.importe_pago, u.usuario
    FROM ta_11_pago_energia p
    LEFT JOIN ta_12_passwords u ON p.id_usuario = u.id_usuario
    WHERE p.id_energia = p_id_energia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_get_condonaciones_energia
-- Tipo: Catalog
-- Descripción: Obtiene las condonaciones de energía para un id_energia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_condonaciones_energia(p_id_energia INT)
RETURNS TABLE (
  id_cancelacion INT,
  id_energia INT,
  axo SMALLINT,
  periodo SMALLINT,
  importe NUMERIC,
  observacion VARCHAR(255),
  usuario VARCHAR(50)
) AS $$
BEGIN
  RETURN QUERY
    SELECT c.id_cancelacion, c.id_energia, c.axo, c.periodo, c.importe, c.observacion, u.usuario
    FROM ta_11_ade_ene_canc c
    LEFT JOIN ta_12_passwords u ON c.id_usuario = u.id_usuario
    WHERE c.id_energia = p_id_energia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

