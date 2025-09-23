-- Stored Procedure: sp_adeudos_ins_validate_contrato
-- Tipo: CRUD
-- Descripción: Valida que el contrato exista, esté vigente y el año sea válido.
-- Generado para formulario: Adeudos_Ins
-- Fecha: 2025-08-27 13:44:07

-- PostgreSQL stored procedure for validating contrato
CREATE OR REPLACE FUNCTION sp_adeudos_ins_validate_contrato(
    p_num_contrato integer,
    p_ctrol_aseo integer,
    p_ejercicio integer
) RETURNS TABLE(success boolean, message text, contrato_id integer) AS $$
DECLARE
    v_control_contrato integer;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo AND status_vigencia = 'V' AND EXTRACT(YEAR FROM aso_mes_oblig) <= p_ejercicio;
    IF FOUND THEN
        RETURN QUERY SELECT true, '', v_control_contrato;
    ELSE
        RETURN QUERY SELECT false, 'Contrato no encontrado o no vigente', NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;