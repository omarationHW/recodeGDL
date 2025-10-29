-- Stored Procedure: pagosmultfrm_get_dependencia
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la dependencia.
-- Generado para formulario: pagosmultfrm
-- Fecha: 2025-08-27 14:09:11

CREATE OR REPLACE FUNCTION pagosmultfrm_get_dependencia(
    p_id_dependencia SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_dependencias
    WHERE id_dependencia = p_id_dependencia;
END;
$$ LANGUAGE plpgsql;