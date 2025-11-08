-- Stored Procedure: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados activos
-- Generado para formulario: ConsRequerimientos
-- Fecha: 2025-08-26 23:23:01

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE (
    id integer,
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer,
    cuenta_energia integer,
    id_zona smallint,
    tipo_emision varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT row_number() OVER (), oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    ORDER BY oficina, num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;