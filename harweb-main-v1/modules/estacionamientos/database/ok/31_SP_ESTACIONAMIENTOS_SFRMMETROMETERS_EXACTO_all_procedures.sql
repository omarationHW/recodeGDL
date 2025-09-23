-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRMMETROMETERS (EXACTO del archivo original)
-- Archivo: 31_SP_ESTACIONAMIENTOS_SFRMMETROMETERS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRMMETROMETERS (EXACTO del archivo original)
-- Archivo: 31_SP_ESTACIONAMIENTOS_SFRMMETROMETERS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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

