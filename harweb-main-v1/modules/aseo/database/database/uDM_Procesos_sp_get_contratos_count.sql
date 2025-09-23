-- Stored Procedure: sp_get_contratos_count
-- Tipo: Report
-- Descripción: Cuenta contratos por ctrol_aseo y status_vigencia (si se provee).
-- Generado para formulario: uDM_Procesos
-- Fecha: 2025-08-27 15:45:14

CREATE OR REPLACE FUNCTION sp_get_contratos_count(ctrol integer, status varchar DEFAULT NULL)
RETURNS TABLE (
    registros integer
) AS $$
BEGIN
    IF status IS NULL THEN
        RETURN QUERY SELECT COUNT(*) FROM ta_16_contratos WHERE ctrol_aseo = ctrol;
    ELSE
        RETURN QUERY SELECT COUNT(*) FROM ta_16_contratos WHERE ctrol_aseo = ctrol AND status_vigencia = status;
    END IF;
END;
$$ LANGUAGE plpgsql;