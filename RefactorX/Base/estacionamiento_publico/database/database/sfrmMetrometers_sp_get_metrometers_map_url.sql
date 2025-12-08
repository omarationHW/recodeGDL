-- Stored Procedure: sp_get_metrometers_map_url
-- Tipo: CRUD
-- Descripción: Devuelve la URL del mapa estático de Google Maps para la ubicación del registro.
-- Generado para formulario: sfrmMetrometers
-- Fecha: 2025-08-27 14:03:33
-- Fix: Alias para evitar ambiguedad

DROP FUNCTION IF EXISTS sp_get_metrometers_map_url(integer, integer);

CREATE OR REPLACE FUNCTION sp_get_metrometers_map_url(p_axo integer, p_folio integer)
RETURNS TABLE (
    map_url text
) AS $$
DECLARE
    v_lat varchar(30);
    v_long varchar(30);
BEGIN
    SELECT t.poslat, t.poslong INTO v_lat, v_long
    FROM ta14_adicional_mmeters t
    WHERE t.axo = p_axo AND t.folio = p_folio;

    IF v_lat IS NULL OR v_long IS NULL THEN
        RETURN QUERY SELECT NULL::text;
    ELSE
        RETURN QUERY SELECT 'https://maps.google.com/maps/api/staticmap?center=' || trim(v_lat) || ',' || trim(v_long) || '&zoom=18&size=512x512&maptype=roadmap&sensor=false&format=jpg&markers=color:blue|' || trim(v_lat) || ',' || trim(v_long);
    END IF;
END;
$$ LANGUAGE plpgsql;