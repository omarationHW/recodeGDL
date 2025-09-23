-- Stored Procedure: get_mercados_by_oficina
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una oficina específica.
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 18:41:59

CREATE OR REPLACE FUNCTION get_mercados_by_oficina(p_oficina integer)
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar(30),
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