-- Stored Procedure: sp_get_catalogo_mercados
-- Versión con categoría desde ta_11_localpaso

CREATE OR REPLACE FUNCTION sp_get_catalogo_mercados(
    p_oficina INTEGER,
    p_nivel_usuario INTEGER
)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    descripcion VARCHAR,
    zona SMALLINT,
    categoria SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        m.oficina, 
        m.num_mercado_nvo, 
        m.descripcion,
        m.zona,
        l.categoria
    FROM public.ta_11_mercados m
    LEFT JOIN public.ta_11_localpaso l 
        ON m.oficina = l.oficina 
        AND m.num_mercado_nvo = l.num_mercado
    WHERE m.num_mercado_nvo < 99
    AND (p_oficina IS NULL OR m.oficina = p_oficina)
    ORDER BY m.oficina ASC, m.num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;
