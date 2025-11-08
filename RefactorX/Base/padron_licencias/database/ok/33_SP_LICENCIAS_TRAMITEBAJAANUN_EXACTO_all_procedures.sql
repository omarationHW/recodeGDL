-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: TRAMITEBAJAANUN (EXACTO del archivo original)
-- Archivo: 33_SP_LICENCIAS_TRAMITEBAJAANUN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_tramite_baja_anun_buscar
-- Tipo: CRUD
-- Descripción: Busca un anuncio, sus saldos y la licencia relacionada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tramite_baja_anun_buscar(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio JSONB,
    saldos JSONB,
    licencia JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        row_to_json(a),
        (SELECT json_agg(row_to_json(s)) FROM detsal_lic s WHERE s.id_anuncio = a.id_anuncio AND s.cvepago = 0),
        row_to_json(l)
    FROM anuncios a
    LEFT JOIN licencias l ON l.id_licencia = a.id_licencia
    WHERE a.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: TRAMITEBAJAANUN (EXACTO del archivo original)
-- Archivo: 33_SP_LICENCIAS_TRAMITEBAJAANUN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: calc_sdosl
-- Tipo: CRUD
-- Descripción: Recalcula el saldo de la licencia (dummy, debe implementarse según lógica de negocio).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION calc_sdosl(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Aquí va la lógica para recalcular el saldo de la licencia
    -- Por ejemplo, sumar los saldos de detsal_lic y actualizar saldos_lic
    -- Esta función debe ser implementada según la lógica real
    NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================

