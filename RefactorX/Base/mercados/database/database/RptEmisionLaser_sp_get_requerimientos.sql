-- Stored Procedure: sp_get_requerimientos
-- Tipo: Report
-- Descripción: Obtiene los requerimientos de un local para un módulo.
-- Generado para formulario: RptEmisionLaser
-- Fecha: 2025-08-27 20:48:44

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo integer, p_id_local integer)
RETURNS TABLE(
  folio integer,
  importe_multa numeric,
  importe_gastos numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT folio, importe_multa, importe_gastos
  FROM ta_15_apremios
  WHERE modulo = p_modulo AND control_otr = p_id_local AND vigencia = '1' AND clave_practicado = 'P'
  ORDER BY folio;
END;
$$ LANGUAGE plpgsql;