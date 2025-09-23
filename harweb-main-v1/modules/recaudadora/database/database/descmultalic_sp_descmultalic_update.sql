-- Stored Procedure: sp_descmultalic_update
-- Tipo: CRUD
-- Descripción: Actualiza un descuento de multa de licencia
-- Generado para formulario: descmultalic
-- Fecha: 2025-08-27 00:04:06

CREATE OR REPLACE FUNCTION sp_descmultalic_update(
    p_id_descto INTEGER,
    p_porcentaje SMALLINT,
    p_autoriza SMALLINT,
    p_useract VARCHAR,
    p_vigencia VARCHAR
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
BEGIN
    UPDATE descmultalic
    SET porcentaje = p_porcentaje,
        autoriza = p_autoriza,
        fecact = CURRENT_DATE,
        useract = p_useract,
        vigencia = p_vigencia
    WHERE id_descto = p_id_descto
    RETURNING id_descto, 'OK';
END;
$$ LANGUAGE plpgsql;