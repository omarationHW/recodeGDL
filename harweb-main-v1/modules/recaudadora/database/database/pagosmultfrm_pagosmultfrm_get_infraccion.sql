-- Stored Procedure: pagosmultfrm_get_infraccion
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la infracción para una dependencia e infracción dada.
-- Generado para formulario: pagosmultfrm
-- Fecha: 2025-08-27 14:09:11

CREATE OR REPLACE FUNCTION pagosmultfrm_get_infraccion(
    p_id_dependencia SMALLINT,
    p_id_infraccion SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_infracciones
    WHERE id_dependencia = p_id_dependencia AND id_infraccion = p_id_infraccion;
END;
$$ LANGUAGE plpgsql;