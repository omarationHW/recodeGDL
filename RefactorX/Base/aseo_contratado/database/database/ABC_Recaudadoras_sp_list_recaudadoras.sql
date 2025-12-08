-- ============================================
-- SP: sp_list_recaudadoras
-- Tipo: CONSULTA
-- Descripción: Lista todas las recaudadoras con búsqueda opcional
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_recaudadoras(p_search VARCHAR DEFAULT NULL)
RETURNS TABLE(
    num_rec SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.num_rec,
        r.descripcion
    FROM ta_16_recaudadoras r
    WHERE
        p_search IS NULL
        OR r.descripcion ILIKE '%' || p_search || '%'
        OR CAST(r.num_rec AS TEXT) LIKE '%' || p_search || '%'
    ORDER BY r.num_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================
