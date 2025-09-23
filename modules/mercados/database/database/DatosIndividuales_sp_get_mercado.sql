-- Stored Procedure: sp_get_mercado
-- Tipo: Catalog
-- Descripción: Obtiene los datos del mercado
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina SMALLINT, p_num_mercado SMALLINT)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR(30),
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia
    FROM ta_11_mercados
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;