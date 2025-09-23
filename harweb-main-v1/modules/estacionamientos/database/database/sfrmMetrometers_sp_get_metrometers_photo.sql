-- Stored Procedure: sp_get_metrometers_photo
-- Tipo: CRUD
-- Descripción: Devuelve la URL de la foto (1 o 2) para un axo y folio.
-- Generado para formulario: sfrmMetrometers
-- Fecha: 2025-08-27 14:03:33

CREATE OR REPLACE FUNCTION sp_get_metrometers_photo(p_axo integer, p_folio integer, p_photo_number integer)
RETURNS TABLE (
    photo_url varchar(100)
) AS $$
BEGIN
    IF p_photo_number = 1 THEN
        RETURN QUERY SELECT linkfoto1 FROM ta14_adicional_mmeters WHERE axo = p_axo AND folio = p_folio;
    ELSIF p_photo_number = 2 THEN
        RETURN QUERY SELECT linkfoto2 FROM ta14_adicional_mmeters WHERE axo = p_axo AND folio = p_folio;
    ELSE
        RETURN QUERY SELECT NULL::varchar(100);
    END IF;
END;
$$ LANGUAGE plpgsql;