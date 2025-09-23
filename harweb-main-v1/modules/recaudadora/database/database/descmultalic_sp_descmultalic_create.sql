-- Stored Procedure: sp_descmultalic_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento de multa para una licencia
-- Generado para formulario: descmultalic
-- Fecha: 2025-08-27 00:04:06

CREATE OR REPLACE FUNCTION sp_descmultalic_create(
    p_id_licencia INTEGER,
    p_porcentaje SMALLINT,
    p_autoriza SMALLINT,
    p_useralta VARCHAR
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM descmultalic WHERE id_licencia = p_id_licencia AND vigencia = 'V';
    IF v_exists > 0 THEN
        RETURN QUERY SELECT NULL, 'Ya existe un descuento vigente para esta licencia';
        RETURN;
    END IF;
    INSERT INTO descmultalic (id_licencia, porcentaje, fecalta, useralta, vigencia, autoriza)
    VALUES (p_id_licencia, p_porcentaje, CURRENT_DATE, p_useralta, 'V', p_autoriza)
    RETURNING id_descto, 'OK';
END;
$$ LANGUAGE plpgsql;