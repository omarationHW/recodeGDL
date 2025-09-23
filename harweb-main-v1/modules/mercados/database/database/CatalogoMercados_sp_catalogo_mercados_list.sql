-- Stored Procedure: sp_catalogo_mercados_list
-- Tipo: Catalog
-- Descripción: Lista todos los mercados activos
-- Generado para formulario: CatalogoMercados
-- Fecha: 2025-08-26 23:04:40

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_list()
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar(30),
    cuenta_ingreso integer,
    cuenta_energia integer,
    id_zona smallint,
    tipo_emision char(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    ORDER BY oficina ASC, num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;