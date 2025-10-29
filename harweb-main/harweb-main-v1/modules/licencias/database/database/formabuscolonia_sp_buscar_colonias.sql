-- Stored Procedure: sp_buscar_colonias
-- Tipo: Catalog
-- Descripción: Busca colonias por municipio (c_mnpio=39) y filtro de nombre (LIKE, insensible a mayúsculas/minúsculas). Devuelve colonia, d_codigopostal, d_tipo_asenta.
-- Generado para formulario: formabuscolonia
-- Fecha: 2025-08-27 17:48:40

CREATE OR REPLACE FUNCTION sp_buscar_colonias(p_c_mnpio integer, p_filtro text)
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
      AND (
        p_filtro IS NULL OR trim(p_filtro) = '' OR
        UPPER(colonia) LIKE '%' || UPPER(p_filtro) || '%'
      )
    ORDER BY colonia;
END;
$$ LANGUAGE plpgsql;