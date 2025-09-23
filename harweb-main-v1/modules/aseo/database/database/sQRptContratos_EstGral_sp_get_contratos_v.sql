-- Stored Procedure: sp_get_contratos_v
-- Tipo: Report
-- Descripción: Obtiene el total de contratos vigentes para un tipo de aseo
-- Generado para formulario: sQRptContratos_EstGral
-- Fecha: 2025-08-27 15:32:18

CREATE OR REPLACE FUNCTION sp_get_contratos_v(ctrol integer)
RETURNS TABLE(registros float) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float as registros FROM contratos WHERE ctrol_aseo = ctrol AND estado = 'VIGENTE';
END;
$$ LANGUAGE plpgsql;