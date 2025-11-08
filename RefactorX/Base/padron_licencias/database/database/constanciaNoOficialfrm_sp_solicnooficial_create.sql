-- Stored Procedure: sp_solicnooficial_create
-- Tipo: CRUD
-- Descripción: Crea una nueva solicitud de número oficial, asignando folio y año automáticamente.
-- Generado para formulario: constanciaNoOficialfrm
-- Fecha: 2025-08-27 17:19:01

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