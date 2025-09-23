-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrmMetrometers
-- Generado: 2025-08-27 14:03:33
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_metrometers_by_axo_folio
-- Tipo: Catalog
-- Descripción: Obtiene los datos de ta14_adicional_mmeters por axo y folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_metrometers_by_axo_folio(p_axo integer, p_folio integer)
RETURNS TABLE (
    axo smallint,
    folio integer,
    direccion varchar(100),
    poslong varchar(30),
    poslat varchar(30),
    marca varchar(30),
    modelo varchar(30),
    linkfoto1 varchar(100),
    linkfoto2 varchar(100),
    motivo varchar(250),
    idmedio integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, folio, direccion, poslong, poslat, marca, modelo, linkfoto1, linkfoto2, motivo, idmedio
    FROM ta14_adicional_mmeters
    WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_metrometers_photo
-- Tipo: CRUD
-- Descripción: Devuelve la URL de la foto (1 o 2) para un axo y folio.
-- --------------------------------------------

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

-- ============================================

-- SP 3/3: sp_get_metrometers_map_url
-- Tipo: CRUD
-- Descripción: Devuelve la URL del mapa estático de Google Maps para la ubicación del registro.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_metrometers_map_url(p_axo integer, p_folio integer)
RETURNS TABLE (
    map_url text
) AS $$
DECLARE
    v_lat varchar(30);
    v_long varchar(30);
BEGIN
    SELECT poslat, poslong INTO v_lat, v_long FROM ta14_adicional_mmeters WHERE axo = p_axo AND folio = p_folio;
    IF v_lat IS NULL OR v_long IS NULL THEN
        RETURN QUERY SELECT NULL::text;
    ELSE
        RETURN QUERY SELECT 'https://maps.google.com/maps/api/staticmap?center=' || trim(v_lat) || ',' || trim(v_long) || '&zoom=18&size=512x512&maptype=roadmap&sensor=false&format=jpg&markers=color:blue|' || trim(v_lat) || ',' || trim(v_long);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

