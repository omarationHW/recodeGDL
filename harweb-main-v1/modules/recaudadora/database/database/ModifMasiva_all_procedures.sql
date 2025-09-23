-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ModifMasiva
-- Generado: 2025-08-27 13:09:31
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_modifmasiva_predial
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de predial en el rango de folios y recaudadora.
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

-- SP 2/8: sp_cancelamasiva_predial
-- Tipo: CRUD
-- Descripción: Cancela masivamente los requerimientos de predial seleccionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelamasiva_predial(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_cancelados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecent IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecejec <= p_fecha THEN
            UPDATE reqpredial SET
                vigencia = 'C',
                feccan = p_fecha,
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

-- SP 3/8: sp_modifmasiva_multa
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de multas en el rango de folios y recaudadora.
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

-- SP 4/8: sp_cancelamasiva_multa
-- Tipo: CRUD
-- Descripción: Cancela masivamente los requerimientos de multas seleccionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelamasiva_multa(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_cancelados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqmultas WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecpract IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecejec <= p_fecha THEN
            UPDATE reqmultas SET
                vigencia = 'C',
                feccan = p_fecha,
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

-- SP 5/8: sp_modifmasiva_licencia
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de licencias en el rango de folios y recaudadora.
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

-- SP 6/8: sp_cancelamasiva_licencia
-- Tipo: CRUD
-- Descripción: Cancela masivamente los requerimientos de licencias seleccionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelamasiva_licencia(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_cancelados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqlicencias WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecprac IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecentejec <= p_fecha THEN
            UPDATE reqlicencias SET
                vigencia = 'C',
                feccan = p_fecha,
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

-- SP 7/8: sp_modifmasiva_anuncio
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de anuncios en el rango de folios y recaudadora.
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

-- SP 8/8: sp_cancelamasiva_anuncio
-- Tipo: CRUD
-- Descripción: Cancela masivamente los requerimientos de anuncios seleccionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelamasiva_anuncio(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_cancelados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqanuncios WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecprac IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecentejec <= p_fecha THEN
            UPDATE reqanuncios SET
                vigencia = 'C',
                feccan = p_fecha,
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

