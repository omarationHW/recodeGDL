-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSTANCIANOOFICIALFRM (EXACTO del archivo original)
-- Archivo: 52_SP_LICENCIAS_CONSTANCIANOOFICIALFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSTANCIANOOFICIALFRM (EXACTO del archivo original)
-- Archivo: 52_SP_LICENCIAS_CONSTANCIANOOFICIALFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CONSTANCIANOOFICIALFRM (EXACTO del archivo original)
-- Archivo: 52_SP_LICENCIAS_CONSTANCIANOOFICIALFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

