-- Stored Procedure: sp_get_con_s
-- Tipo: Report
-- Descripción: Obtiene registros e importe de contenedores condonados
-- Generado para formulario: sQRptContratos_EstGral
-- Fecha: 2025-08-27 15:32:18

CREATE OR REPLACE FUNCTION sp_get_con_s(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CON' AND estado = 'CONDONADO';
END;
$$ LANGUAGE plpgsql;