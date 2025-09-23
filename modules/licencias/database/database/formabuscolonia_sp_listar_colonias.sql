-- Stored Procedure: sp_listar_colonias
-- Tipo: Catalog
-- Descripción: Lista todas las colonias del municipio c_mnpio=39.
-- Generado para formulario: formabuscolonia
-- Fecha: 2025-08-26 16:26:36

CREATE OR REPLACE FUNCTION sp_listar_colonias(p_c_mnpio integer)
RETURNS TABLE(
    colonia text,
    d_codigopostal integer,
    d_tipo_asenta text
) AS $$
BEGIN
    RETURN QUERY
    SELECT colonia, d_codigopostal, d_tipo_asenta
    FROM cp_correos
    WHERE c_mnpio = p_c_mnpio
    ORDER BY colonia;
END;
$$ LANGUAGE plpgsql;