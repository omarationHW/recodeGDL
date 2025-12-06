-- Stored Procedure: sp_get_catalogo_mercados
-- Versión con parámetros para filtrar por oficina y nivel de usuario
-- Compatible con LocalesMtto y LocalesModif

CREATE OR REPLACE FUNCTION sp_get_catalogo_mercados(
    p_oficina INTEGER,
    p_nivel_usuario INTEGER
)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona SMALLINT,
    zona VARCHAR,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.oficina, 
        a.num_mercado_nvo, 
        a.categoria, 
        a.descripcion, 
        a.cuenta_ingreso, 
        a.cuenta_energia, 
        a.id_zona, 
        b.zona, 
        a.tipo_emision
    FROM public.ta_11_mercados a
    LEFT JOIN public.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.num_mercado_nvo < 99
    AND (p_oficina IS NULL OR a.oficina = p_oficina)
    ORDER BY a.oficina ASC, a.num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;
