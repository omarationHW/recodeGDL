-- Stored Procedure: pagosmultfrm_get_ley
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la ley para una dependencia y ley dada.
-- Generado para formulario: pagosmultfrm
-- Fecha: 2025-08-27 14:09:11

CREATE OR REPLACE FUNCTION pagosmultfrm_get_ley(
    p_id_dependencia SMALLINT,
    p_id_ley SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_leyes
    WHERE id_dependencia = p_id_dependencia AND id_ley = p_id_ley;
END;
$$ LANGUAGE plpgsql;