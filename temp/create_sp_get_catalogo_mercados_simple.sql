-- Stored Procedure: sp_get_catalogo_mercados
-- Versión simplificada sin JOIN a ta_12_zonas

CREATE OR REPLACE FUNCTION sp_get_catalogo_mercados(
    p_oficina INTEGER,
    p_nivel_usuario INTEGER
)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    descripcion VARCHAR,
    zona SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.oficina, 
        a.num_mercado_nvo, 
        a.descripcion,
        a.zona
    FROM public.ta_11_mercados a
    WHERE a.num_mercado_nvo < 99
    AND (p_oficina IS NULL OR a.oficina = p_oficina)
    ORDER BY a.oficina ASC, a.num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;
