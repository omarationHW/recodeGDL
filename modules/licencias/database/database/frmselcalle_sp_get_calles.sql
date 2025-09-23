-- Stored Procedure: sp_get_calles
-- Tipo: Catalog
-- Descripción: Obtiene todas las calles o filtra por nombre usando prefijo (como 'matches' en Delphi).
-- Generado para formulario: frmselcalle
-- Fecha: 2025-08-27 18:05:20

CREATE OR REPLACE FUNCTION sp_get_calles(filter TEXT DEFAULT '')
RETURNS TABLE (cvecalle INTEGER, calle TEXT) AS $$
BEGIN
    IF filter IS NULL OR trim(filter) = '' THEN
        RETURN QUERY SELECT cvecalle, calle FROM c_calles ORDER BY calle;
    ELSE
        RETURN QUERY SELECT cvecalle, calle FROM c_calles WHERE calle ILIKE filter || '%' ORDER BY calle;
    END IF;
END;
$$ LANGUAGE plpgsql;