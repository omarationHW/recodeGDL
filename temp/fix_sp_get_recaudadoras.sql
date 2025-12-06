-- Corregir tipo de datos en sp_get_recaudadoras
-- El campo recaudadora es CHAR(50), no VARCHAR

DROP FUNCTION IF EXISTS sp_get_recaudadoras();

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE (
    id_rec SMALLINT,
    recaudadora CHAR(50)  -- Cambiado de VARCHAR a CHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec,
        r.recaudadora
    FROM padron_licencias.comun.ta_12_recaudadoras r
    WHERE r.id_rec > 0
    ORDER BY r.id_rec;
END;
$$;
