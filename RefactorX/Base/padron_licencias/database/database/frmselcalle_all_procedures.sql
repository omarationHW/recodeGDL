-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: frmselcalle
-- Generado: 2025-08-27 18:05:20
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_calles
-- Tipo: Catalog
-- Descripción: Obtiene todas las calles o filtra por nombre usando prefijo (como 'matches' en Delphi).
-- --------------------------------------------

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

-- ============================================

-- SP 2/2: sp_get_calle_by_ids
-- Tipo: Catalog
-- Descripción: Obtiene las calles por una lista de IDs separados por coma.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_calle_by_ids(ids_csv TEXT)
RETURNS TABLE (cvecalle INTEGER, calle TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, calle
    FROM c_calles
    WHERE cvecalle = ANY (string_to_array(ids_csv, ',')::int[]);
END;
$$ LANGUAGE plpgsql;

-- ============================================

