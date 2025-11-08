-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSTANCIAFRM (EXACTO del archivo original)
-- Archivo: 53_SP_LICENCIAS_CONSTANCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_constancia_create
-- Tipo: CRUD
-- Descripción: Crea una nueva constancia, actualiza el folio en parametros y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_constancia_create(
    p_tipo smallint,
    p_solicita varchar,
    p_partidapago varchar default null,
    p_observacion varchar default null,
    p_domicilio varchar default null,
    p_id_licencia integer default null,
    p_capturista varchar
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
DECLARE
    v_folio integer;
    v_axo integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    SELECT constancia INTO v_folio FROM parametros ORDER BY id DESC LIMIT 1;
    v_folio := COALESCE(v_folio, 0) + 1;
    UPDATE parametros SET constancia = v_folio;
    INSERT INTO constancias(axo, folio, tipo, solicita, partidapago, observacion, domicilio, id_licencia, vigente, feccap, capturista)
    VALUES (v_axo, v_folio, p_tipo, p_solicita, p_partidapago, p_observacion, p_domicilio, p_id_licencia, 'V', CURRENT_DATE, p_capturista);
    RETURN QUERY SELECT * FROM constancias WHERE axo = v_axo AND folio = v_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSTANCIAFRM (EXACTO del archivo original)
-- Archivo: 53_SP_LICENCIAS_CONSTANCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_constancia_cancel
-- Tipo: CRUD
-- Descripción: Cancela una constancia y registra el motivo en observacion.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_constancia_cancel(
    p_axo integer,
    p_folio integer,
    p_observacion varchar
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    UPDATE constancias SET
        vigente = 'C',
        observacion = p_observacion
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT * FROM constancias WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSTANCIAFRM (EXACTO del archivo original)
-- Archivo: 53_SP_LICENCIAS_CONSTANCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_constancia_search
-- Tipo: Catalog
-- Descripción: Busca constancias por axo/folio, id_licencia o fecha de captura.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_constancia_search(
    p_axo integer default null,
    p_folio integer default null,
    p_id_licencia integer default null,
    p_feccap date default null
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    RETURN QUERY SELECT * FROM constancias
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_id_licencia IS NULL OR id_licencia = p_id_licencia)
      AND (p_feccap IS NULL OR feccap = p_feccap)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSTANCIAFRM (EXACTO del archivo original)
-- Archivo: 53_SP_LICENCIAS_CONSTANCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

