-- Stored Procedure: sp_get_catalogo_mercados
-- Tipo: Catalog
-- Descripción: Obtiene el listado de mercados municipales con zona y recaudadora.
-- Generado para formulario: RptCatalogoMerc
-- Fecha: 2025-08-27 00:48:02

CREATE OR REPLACE FUNCTION sp_get_catalogo_mercados()
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona SMALLINT,
    zona VARCHAR,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.oficina, a.num_mercado_nvo, a.categoria, a.descripcion, a.cuenta_ingreso, a.cuenta_energia, a.id_zona, b.zona, a.tipo_emision
    FROM ta_11_mercados a
    JOIN ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.num_mercado_nvo < 99
    ORDER BY a.oficina ASC, a.num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;