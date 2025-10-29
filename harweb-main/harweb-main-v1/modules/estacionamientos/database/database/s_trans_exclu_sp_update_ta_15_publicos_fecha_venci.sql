-- Stored Procedure: sp_update_ta_15_publicos_fecha_venci
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de vencimiento (pol_fec_ven) en ta_15_publicos según sector, categoría y número.
-- Generado para formulario: sFrm_trans_exclu
-- Fecha: 2025-08-27 14:36:07

CREATE OR REPLACE FUNCTION sp_update_ta_15_publicos_fecha_venci(
    p_fec_venci date,
    p_sector varchar,
    p_categ varchar,
    p_num integer
) RETURNS integer AS $$
DECLARE
    updated_count integer;
BEGIN
    UPDATE ta_15_publicos
    SET pol_fec_ven = p_fec_venci
    WHERE cve_sector = p_sector AND cve_categ = p_categ AND cve_numero = p_num;
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;