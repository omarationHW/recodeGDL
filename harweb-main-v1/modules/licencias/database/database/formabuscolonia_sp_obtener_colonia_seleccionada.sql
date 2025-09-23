-- Stored Procedure: sp_obtener_colonia_seleccionada
-- Tipo: Catalog
-- Descripción: Obtiene los datos de una colonia específica por municipio (c_mnpio=39) y nombre exacto de colonia.
-- Generado para formulario: formabuscolonia
-- Fecha: 2025-08-27 17:48:40

CREATE OR REPLACE FUNCTION sp_obtener_colonia_seleccionada(p_c_mnpio integer, p_colonia text)
RETURNS TABLE (
    colonia text,
    d_codigopostal integer,
    d_tipo_asenta text
) AS $$
BEGIN
    RETURN QUERY
    SELECT colonia, d_codigopostal, d_tipo_asenta
    FROM cp_correos
    WHERE c_mnpio = p_c_mnpio
      AND colonia = p_colonia
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;