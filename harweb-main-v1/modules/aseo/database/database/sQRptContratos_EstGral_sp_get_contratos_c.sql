-- Stored Procedure: sp_get_contratos_c
-- Tipo: Report
-- Descripción: Obtiene el total de contratos cancelados para un tipo de aseo
-- Generado para formulario: sQRptContratos_EstGral
-- Fecha: 2025-08-27 15:32:18

CREATE OR REPLACE FUNCTION sp_get_contratos_c(ctrol integer)
RETURNS TABLE(registros float) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float as registros FROM contratos WHERE ctrol_aseo = ctrol AND estado = 'CANCELADO';
END;
$$ LANGUAGE plpgsql;