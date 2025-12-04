-- ============================================
-- SP: sp_get_recaudadoras
-- Descripción: Obtiene el catálogo de oficinas recaudadoras
-- Esquema: padron_licencias.comun (ta_12_recaudadoras)
-- Componente: RptMovimientos.vue
-- ============================================

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(60),
    domicilio VARCHAR(60),
    tel VARCHAR(15),
    recaudador VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec,
        r.id_zona,
        r.recaudadora::VARCHAR(60),
        r.domicilio::VARCHAR(60),
        r.tel::VARCHAR(15),
        r.recaudador::VARCHAR(60)
    FROM comun.ta_12_recaudadoras r
    ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TEST DATA
-- ============================================
-- SELECT * FROM sp_get_recaudadoras();
