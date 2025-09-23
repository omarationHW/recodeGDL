-- Stored Procedure: sp_catalogo_mntto_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados (catálogo completo)
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_list()
RETURNS TABLE (
    oficina INTEGER,
    num_mercado_nvo INTEGER,
    categoria INTEGER,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona INTEGER,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    WHERE tipo_emision <> 'B'
    ORDER BY oficina ASC, num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;