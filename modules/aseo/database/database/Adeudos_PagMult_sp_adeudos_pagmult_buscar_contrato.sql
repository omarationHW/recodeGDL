-- Stored Procedure: sp_adeudos_pagmult_buscar_contrato
-- Tipo: CRUD
-- Descripción: Busca un contrato por número y tipo de aseo.
-- Generado para formulario: Adeudos_PagMult
-- Fecha: 2025-08-27 13:51:30

CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_buscar_contrato(p_num_contrato integer, p_ctrol_aseo integer)
RETURNS TABLE(control_contrato integer, num_contrato integer, ctrol_aseo integer) AS $$
BEGIN
    RETURN QUERY
    SELECT control_contrato, num_contrato, ctrol_aseo
    FROM ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;