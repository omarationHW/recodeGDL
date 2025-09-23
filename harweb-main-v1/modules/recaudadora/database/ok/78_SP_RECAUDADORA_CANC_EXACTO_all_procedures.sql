-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CANC (EXACTO del archivo original)
-- Archivo: 78_SP_RECAUDADORA_CANC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: spd_updreasigna
-- Tipo: CRUD
-- Descripción: Reasigna folios de un ejecutor a otro en un rango y tipo de requerimiento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_updreasigna(
    p_eje INTEGER,
    p_reca INTEGER,
    p_folini INTEGER,
    p_folfin INTEGER,
    p_ejenvo INTEGER,
    p_fecha DATE,
    p_cta INTEGER,
    p_opc INTEGER
) RETURNS TABLE(cambiavig INTEGER, cambiapag INTEGER, nocambiados INTEGER) AS $$
DECLARE
    v_table TEXT;
    v_sql TEXT;
    v_cambiavig INTEGER := 0;
    v_cambiapag INTEGER := 0;
    v_nocambiados INTEGER := 0;
BEGIN
    -- Determinar tabla según p_opc
    CASE p_opc
        WHEN 1 THEN v_table := 'reqpredial';
        WHEN 2 THEN v_table := 'reqmultas';
        WHEN 3 THEN v_table := 'reqlicencias';
        WHEN 4 THEN v_table := 'reqanuncios';
        WHEN 5 THEN v_table := 'reqdiftransmision';
        ELSE RAISE EXCEPTION 'Opción inválida';
    END CASE;
    -- Actualizar ejecutor en folios vigentes
    v_sql := format('UPDATE %I SET cveejecut = $1, fecejec = $2 WHERE recaud = $3 AND folioreq BETWEEN $4 AND $5 AND cveejecut = $6 AND vigencia = ''V''', v_table);
    EXECUTE v_sql USING p_ejenvo, p_fecha, p_reca, p_folini, p_folfin, p_eje;
    GET DIAGNOSTICS v_cambiavig = ROW_COUNT;
    -- Actualizar ejecutor en folios pagados
    v_sql := format('UPDATE %I SET cveejecut = $1, fecejec = $2 WHERE recaud = $3 AND folioreq BETWEEN $4 AND $5 AND cveejecut = $6 AND vigencia = ''P''', v_table);
    EXECUTE v_sql USING p_ejenvo, p_fecha, p_reca, p_folini, p_folfin, p_eje;
    GET DIAGNOSTICS v_cambiapag = ROW_COUNT;
    -- Contar folios no modificados
    v_sql := format('SELECT COUNT(*) FROM %I WHERE recaud = $1 AND folioreq BETWEEN $2 AND $3 AND cveejecut = $4 AND vigencia NOT IN (''V'',''P'')', v_table);
    EXECUTE v_sql INTO v_nocambiados USING p_reca, p_folini, p_folfin, p_eje;
    RETURN QUERY SELECT v_cambiavig, v_cambiapag, v_nocambiados;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CANC (EXACTO del archivo original)
-- Archivo: 78_SP_RECAUDADORA_CANC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

