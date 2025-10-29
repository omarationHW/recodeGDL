-- Stored Procedure: sp_catalogo_mntto_get
-- Tipo: Catalog
-- Descripción: Obtiene un mercado por ID compuesto (oficina, num_mercado_nvo)
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_get(p_oficina INTEGER, p_num_mercado_nvo INTEGER)
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
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;