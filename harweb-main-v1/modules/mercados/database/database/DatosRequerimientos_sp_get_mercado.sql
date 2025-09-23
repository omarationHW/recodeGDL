-- Stored Procedure: sp_get_mercado
-- Tipo: Catalog
-- Descripción: Obtiene los datos de un mercado por oficina y num_mercado
-- Generado para formulario: DatosRequerimientos
-- Fecha: 2025-08-26 23:47:56

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina smallint, p_num_mercado smallint)
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer,
    cuenta_energia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia
    FROM ta_11_mercados
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;