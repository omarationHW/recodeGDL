-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: REACTIVA_FOLIOS (EXACTO del archivo original)
-- Archivo: 19_SP_ESTACIONAMIENTOS_REACTIVA_FOLIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_reactiva_folios_buscar
-- Tipo: Catalog
-- Descripción: Busca un folio en ta14_folios_histo por placa+folio o axo+folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_reactiva_folios_buscar(
    p_opcion integer, -- 0=por placa+folio, 1=por axo+folio
    p_placa varchar(7),
    p_axo integer,
    p_folio integer
)
RETURNS TABLE (
    control integer,
    axo integer,
    folio integer,
    fecha_folio date,
    placa varchar(7),
    infraccion integer,
    estado integer,
    vigilante integer,
    num_acuerdo integer,
    fec_cap date,
    usu_inicial integer,
    zona integer,
    espacio integer
) AS $$
BEGIN
    IF p_opcion = 0 THEN
        RETURN QUERY
        SELECT control, axo, folio, fecha_folio, placa, infraccion, estado, vigilante, num_acuerdo, fec_cap, usu_inicial, zona, espacio
        FROM ta14_folios_histo
        WHERE placa = UPPER(TRIM(p_placa)) AND folio = p_folio;
    ELSE
        RETURN QUERY
        SELECT control, axo, folio, fecha_folio, placa, infraccion, estado, vigilante, num_acuerdo, fec_cap, usu_inicial, zona, espacio
        FROM ta14_folios_histo
        WHERE axo = p_axo AND folio = p_folio;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: REACTIVA_FOLIOS (EXACTO del archivo original)
-- Archivo: 19_SP_ESTACIONAMIENTOS_REACTIVA_FOLIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

