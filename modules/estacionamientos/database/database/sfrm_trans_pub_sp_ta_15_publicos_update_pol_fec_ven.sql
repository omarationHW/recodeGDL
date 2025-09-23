-- Stored Procedure: sp_ta_15_publicos_update_pol_fec_ven
-- Tipo: CRUD
-- Descripción: Actualiza el campo pol_fec_ven en ta_15_publicos para un registro específico.
-- Generado para formulario: sfrm_trans_pub
-- Fecha: 2025-08-27 14:38:19

CREATE OR REPLACE FUNCTION sp_ta_15_publicos_update_pol_fec_ven(
    p_sector VARCHAR,
    p_categ VARCHAR,
    p_numero VARCHAR,
    p_fec_venci VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
    v_fec_venci DATE;
BEGIN
    IF p_fec_venci IS NULL OR p_fec_venci = '00/00/00' THEN
        v_fec_venci := NULL;
    ELSE
        v_fec_venci := to_date(p_fec_venci, 'DD/MM/YY');
    END IF;
    UPDATE ta_15_publicos
    SET pol_fec_ven = v_fec_venci
    WHERE cve_sector = p_sector AND cve_categ = p_categ AND cve_numero = p_numero;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;