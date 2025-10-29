-- Stored Procedure: get_apremios_adeudos_vencidos
-- Tipo: Report
-- Descripción: Obtiene los apremios (requerimientos, multas, gastos) asociados a un contrato.
-- Generado para formulario: Adeudos_Venc
-- Fecha: 2025-08-27 13:57:03

CREATE OR REPLACE FUNCTION get_apremios_adeudos_vencidos(p_control_contrato INTEGER)
RETURNS TABLE (
  id_control INTEGER,
  modulo SMALLINT,
  control_otr INTEGER,
  folio INTEGER,
  importe_multa NUMERIC,
  importe_gastos NUMERIC,
  fecha_practicado DATE,
  clave_practicado VARCHAR,
  porcentaje_multa SMALLINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_control, modulo, control_otr, folio, importe_multa, importe_gastos, fecha_practicado, clave_practicado, porcentaje_multa
  FROM ta_15_apremios
  WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P'
  ORDER BY id_control;
END;
$$ LANGUAGE plpgsql;