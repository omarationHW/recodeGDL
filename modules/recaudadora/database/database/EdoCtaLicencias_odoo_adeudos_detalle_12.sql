-- Stored Procedure: odoo_adeudos_detalle_12
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para impresión de estado de cuenta/licencias.
-- Generado para formulario: EdoCtaLicencias
-- Fecha: 2025-08-27 01:16:30

CREATE OR REPLACE FUNCTION odoo_adeudos_detalle_12(p_tipo varchar, p_numero integer, p_rec integer, p_forma_pago varchar, p_identificador integer)
RETURNS TABLE (
  norubro integer,
  noconcepto integer,
  cta_aplic integer,
  referencia varchar,
  descripcion varchar,
  monto numeric,
  acumulado numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM v_adeudos_detalle WHERE tipo = p_tipo AND numero = p_numero AND rec = p_rec AND forma_pago = p_forma_pago AND identificador = p_identificador;
END;
$$ LANGUAGE plpgsql;