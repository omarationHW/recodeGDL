-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: IMPREQCVECAT (EXACTO del archivo original)
-- Archivo: 97_SP_RECAUDADORA_IMPREQCVECAT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_asignar_requerimientos
-- Tipo: CRUD
-- Descripción: Asigna requerimientos a un ejecutor en un rango de folios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_asignar_requerimientos(
    p_recaud INTEGER, p_folioini INTEGER, p_foliofin INTEGER, p_ejecutor INTEGER, p_fecha DATE
) RETURNS TABLE(folio INTEGER, status TEXT) AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = p_ejecutor, fecejec = p_fecha
    WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin AND vigencia = 'V';
    RETURN QUERY SELECT folioreq, 'asignado' FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: IMPREQCVECAT (EXACTO del archivo original)
-- Archivo: 97_SP_RECAUDADORA_IMPREQCVECAT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_lista_ejecutores
-- Tipo: Catalog
-- Descripción: Lista ejecutores disponibles para una recaudadora y fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_lista_ejecutores(
    p_recaud INTEGER, p_fecha DATE
) RETURNS TABLE(cveejecutor INTEGER, ncompleto TEXT, asignar INTEGER, ultfec_entrega DATE) AS $$
BEGIN
    RETURN QUERY SELECT cveejecutor, ncompleto, asignados, ultfec_entrega FROM ejecutores WHERE recaud = p_recaud AND (vigencia = 'V' OR (ultfec_entrega = p_fecha));
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: IMPREQCVECAT (EXACTO del archivo original)
-- Archivo: 97_SP_RECAUDADORA_IMPREQCVECAT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

