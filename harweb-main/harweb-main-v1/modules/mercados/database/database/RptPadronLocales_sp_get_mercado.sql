-- Stored Procedure: sp_get_mercado
-- Tipo: Catalog
-- Descripción: Obtiene información de los mercados de una recaudadora.
-- Generado para formulario: RptPadronLocales
-- Fecha: 2025-08-27 01:27:45

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina INTEGER)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR(60),
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona SMALLINT,
    tipo_emision VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    WHERE oficina = p_oficina AND tipo_emision <> 'B'
    ORDER BY oficina, num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;