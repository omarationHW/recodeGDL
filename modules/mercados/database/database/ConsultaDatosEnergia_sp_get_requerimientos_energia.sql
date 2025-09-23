-- Stored Procedure: sp_get_requerimientos_energia
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos de energía para un local
-- Generado para formulario: ConsultaDatosEnergia
-- Fecha: 2025-08-26 23:25:04

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