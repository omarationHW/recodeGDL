-- Stored Procedure: sp_get_calle_by_ids
-- Tipo: Catalog
-- Descripción: Obtiene las calles por una lista de IDs separados por coma.
-- Generado para formulario: frmselcalle
-- Fecha: 2025-08-27 18:05:20

CREATE OR REPLACE FUNCTION sp_get_calle_by_ids(ids_csv TEXT)
RETURNS TABLE (cvecalle INTEGER, calle TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, calle
    FROM c_calles
    WHERE cvecalle = ANY (string_to_array(ids_csv, ',')::int[]);
END;
$$ LANGUAGE plpgsql;