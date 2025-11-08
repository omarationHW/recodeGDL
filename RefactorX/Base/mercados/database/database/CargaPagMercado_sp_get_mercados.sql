-- Stored Procedure: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene los mercados de una recaudadora/oficina
-- Generado para formulario: CargaPagMercado
-- Fecha: 2025-08-26 22:58:28

CREATE OR REPLACE FUNCTION sp_get_mercados(p_oficina integer)
RETURNS TABLE(
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso
    FROM ta_11_mercados
    WHERE oficina = p_oficina
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;