-- Stored Procedure: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados activos para la carga de pagos especial.
-- Generado para formulario: CargaPagEspecial
-- Fecha: 2025-08-26 22:54:46

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso
    FROM ta_11_mercados
    WHERE oficina = 4 AND num_mercado_nvo < 49
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;