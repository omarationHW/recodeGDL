-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MODIFMASIVA (EXACTO del archivo original)
-- Archivo: 65_SP_RECAUDADORA_MODIFMASIVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 1/8: sp_modifmasiva_predial
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de predial en el rango de folios y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_modifmasiva_predial(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_modificados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecent IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecejec <= p_fecha THEN
            UPDATE reqpredial SET
                fecent = p_fecha,
                nodiligenciado = 'N',
                capturista = p_user,
                feccap = CURRENT_DATE
            WHERE cvereq = r.cvereq;
            v_count := v_count + 1;
        END IF;
    END LOOP;
    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MODIFMASIVA (EXACTO del archivo original)
-- Archivo: 65_SP_RECAUDADORA_MODIFMASIVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 3/8: sp_modifmasiva_multa
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de multas en el rango de folios y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_modifmasiva_multa(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_modificados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqmultas WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecpract IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecejec <= p_fecha THEN
            UPDATE reqmultas SET
                fecpract = p_fecha,
                nodiligenciado = 'N',
                feccap = CURRENT_DATE,
                capturista = p_user
            WHERE cvereq = r.cvereq;
            v_count := v_count + 1;
        END IF;
    END LOOP;
    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MODIFMASIVA (EXACTO del archivo original)
-- Archivo: 65_SP_RECAUDADORA_MODIFMASIVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 5/8: sp_modifmasiva_licencia
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de licencias en el rango de folios y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_modifmasiva_licencia(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_modificados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqlicencias WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecprac IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecentejec <= p_fecha THEN
            UPDATE reqlicencias SET
                fecprac = p_fecha,
                nodiligenciado = 'N',
                feccap = CURRENT_DATE,
                capturista = p_user
            WHERE cvereq = r.cvereq;
            v_count := v_count + 1;
        END IF;
    END LOOP;
    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MODIFMASIVA (EXACTO del archivo original)
-- Archivo: 65_SP_RECAUDADORA_MODIFMASIVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

-- SP 7/8: sp_modifmasiva_anuncio
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de anuncios en el rango de folios y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_modifmasiva_anuncio(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_modificados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqanuncios WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecprac IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecentejec <= p_fecha THEN
            UPDATE reqanuncios SET
                fecprac = p_fecha,
                nodiligenciado = 'N',
                feccap = CURRENT_DATE,
                capturista = p_user
            WHERE cvereq = r.cvereq;
            v_count := v_count + 1;
        END IF;
    END LOOP;
    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MODIFMASIVA (EXACTO del archivo original)
-- Archivo: 65_SP_RECAUDADORA_MODIFMASIVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 8 (EXACTO)
-- ============================================

