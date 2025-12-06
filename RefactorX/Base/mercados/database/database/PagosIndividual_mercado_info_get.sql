-- Stored Procedure: mercado_info_get
-- Tipo: Catalog
-- Descripción: Obtiene información de un mercado por oficina y número de mercado.
-- Generado para formulario: PagosIndividual
-- Fecha: 2025-08-27 00:24:24

CREATE OR REPLACE FUNCTION mercado_info_get(p_oficina integer, p_num_mercado_nvo integer)
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar(35),
    cuenta_ingreso integer,
    cuenta_energia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia
    FROM public.ta_11_mercados
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;