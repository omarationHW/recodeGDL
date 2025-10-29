-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: constanciaNoOficialfrm
-- Generado: 2025-08-27 17:19:01
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_solicnooficial_create
-- Tipo: CRUD
-- Descripción: Crea una nueva solicitud de número oficial, asignando folio y año automáticamente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_solicnooficial_create(
    p_propietario VARCHAR,
    p_actividad VARCHAR,
    p_ubicacion VARCHAR,
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_capturista VARCHAR,
    p_feccap DATE
) RETURNS TABLE(axo INT, folio INT, propietario VARCHAR, actividad VARCHAR, ubicacion VARCHAR, zona SMALLINT, subzona SMALLINT, vigente VARCHAR, feccap DATE, capturista VARCHAR) AS $$
DECLARE
    nvofolio INT;
    nvoaxo INT := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    -- Obtener el último folio del año
    SELECT COALESCE(MAX(folio), 0) + 1 INTO nvofolio FROM solicnooficial WHERE axo = nvoaxo;
    INSERT INTO solicnooficial(axo, folio, propietario, actividad, ubicacion, zona, subzona, vigente, feccap, capturista)
    VALUES (nvoaxo, nvofolio, p_propietario, p_actividad, p_ubicacion, p_zona, p_subzona, 'V', p_feccap, p_capturista)
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_solicnooficial_update
-- Tipo: CRUD
-- Descripción: Actualiza una solicitud de número oficial existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_solicnooficial_update(
    p_axo INT,
    p_folio INT,
    p_propietario VARCHAR,
    p_actividad VARCHAR,
    p_ubicacion VARCHAR,
    p_zona SMALLINT,
    p_subzona SMALLINT
) RETURNS TABLE(axo INT, folio INT, propietario VARCHAR, actividad VARCHAR, ubicacion VARCHAR, zona SMALLINT, subzona SMALLINT, vigente VARCHAR, feccap DATE, capturista VARCHAR) AS $$
BEGIN
    UPDATE solicnooficial
    SET propietario = COALESCE(p_propietario, propietario),
        actividad = COALESCE(p_actividad, actividad),
        ubicacion = COALESCE(p_ubicacion, ubicacion),
        zona = COALESCE(p_zona, zona),
        subzona = COALESCE(p_subzona, subzona)
    WHERE axo = p_axo AND folio = p_folio
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_solicnooficial_cancel
-- Tipo: CRUD
-- Descripción: Cancela una solicitud de número oficial (marca como 'C').
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_solicnooficial_cancel(
    p_axo INT,
    p_folio INT
) RETURNS TABLE(axo INT, folio INT, vigente VARCHAR) AS $$
BEGIN
    UPDATE solicnooficial
    SET vigente = 'C'
    WHERE axo = p_axo AND folio = p_folio
    RETURNING axo, folio, vigente;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_solicnooficial_print
-- Tipo: Report
-- Descripción: Genera los datos necesarios para imprimir la solicitud (puede devolver URL de PDF generado).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_solicnooficial_print(
    p_axo INT,
    p_folio INT
) RETURNS TABLE(pdf_url TEXT) AS $$
DECLARE
    v_pdf_url TEXT;
BEGIN
    -- Aquí se debe implementar la lógica para generar el PDF y devolver la URL
    -- Por ejemplo, llamar a un microservicio o función interna
    v_pdf_url := '/pdf/solicnooficial/' || p_axo || '-' || p_folio || '.pdf';
    RETURN QUERY SELECT v_pdf_url;
END;
$$ LANGUAGE plpgsql;

-- ============================================

