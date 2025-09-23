-- Stored Procedure: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados con tipo_emision = 'D' (Mercado Libertad).
-- Generado para formulario: IngresoLib
-- Fecha: 2025-08-27 00:06:35

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    descripcion varchar,
    cuenta_ingreso integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, descripcion, cuenta_ingreso
    FROM ta_11_mercados
    WHERE tipo_emision = 'D'
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;