-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: constanciafrm
-- Generado: 2025-08-26 15:37:55
-- Total SPs: 6
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

-- SP 2/6: sp_constancia_update
-- Tipo: CRUD
-- Descripción: Actualiza los campos editables de una constancia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_constancia_update(
    p_axo integer,
    p_folio integer,
    p_observacion varchar default null,
    p_partidapago varchar default null,
    p_domicilio varchar default null,
    p_solicita varchar default null
) RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    UPDATE constancias SET
        observacion = COALESCE(p_observacion, observacion),
        partidapago = COALESCE(p_partidapago, partidapago),
        domicilio = COALESCE(p_domicilio, domicilio),
        solicita = COALESCE(p_solicita, solicita)
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT * FROM constancias WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/6: sp_constancia_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las constancias ordenadas por año y folio descendente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_constancia_list()
RETURNS TABLE(axo integer, folio integer, id_licencia integer, solicita varchar, partidapago varchar, observacion varchar, domicilio varchar, tipo smallint, vigente varchar, feccap date, capturista varchar) AS $$
BEGIN
    RETURN QUERY SELECT * FROM constancias ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

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

-- SP 6/6: print_constancia
-- Tipo: Report
-- Descripción: Genera el PDF de la constancia y retorna la URL o base64.
-- --------------------------------------------

-- Este SP debe ser implementado con una herramienta de generación de PDF (ej. pg-pdfgen, o integración con Laravel). Ejemplo:
CREATE OR REPLACE FUNCTION print_constancia(p_axo integer, p_folio integer)
RETURNS TABLE(pdf_url text) AS $$
DECLARE
    v_url text;
BEGIN
    -- Aquí se debe generar el PDF y guardar en storage, luego devolver la URL
    v_url := '/storage/constancias/' || p_axo || '_' || p_folio || '.pdf';
    RETURN QUERY SELECT v_url;
END;
$$ LANGUAGE plpgsql;

-- ============================================

