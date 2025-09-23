-- Stored Procedure: sp_buscar_contrato
-- Tipo: CRUD
-- Descripción: Busca un contrato por número y tipo de aseo.
-- Generado para formulario: ReqsCons
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_buscar_contrato(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE(control_contrato INTEGER, status_vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT control_contrato, status_vigencia FROM ta_16_contratos WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;