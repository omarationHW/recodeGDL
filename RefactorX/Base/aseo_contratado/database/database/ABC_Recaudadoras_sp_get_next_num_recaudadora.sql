-- ============================================
-- SP: sp_get_next_num_recaudadora
-- Tipo: UTILIDAD
-- Descripción: Obtiene el siguiente número disponible para recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_next_num_recaudadora()
RETURNS TABLE(next_num SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(MAX(num_rec), 0) + 1 AS next_num
    FROM ta_16_recaudadoras;
END;
$$ LANGUAGE plpgsql;

-- ============================================
