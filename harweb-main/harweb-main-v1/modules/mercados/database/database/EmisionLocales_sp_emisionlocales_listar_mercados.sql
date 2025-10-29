-- Stored Procedure: sp_emisionlocales_listar_mercados
-- Tipo: Catalog
-- Descripción: Lista los mercados activos de una recaudadora/oficina
-- Generado para formulario: EmisionLocales
-- Fecha: 2025-08-26 23:54:25

CREATE OR REPLACE FUNCTION sp_emisionlocales_listar_mercados(p_oficina INTEGER)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, tipo_emision
    FROM ta_11_mercados
    WHERE oficina = p_oficina AND tipo_emision <> 'B'
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;