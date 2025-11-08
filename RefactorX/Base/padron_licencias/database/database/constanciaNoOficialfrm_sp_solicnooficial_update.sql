-- Stored Procedure: sp_solicnooficial_update
-- Tipo: CRUD
-- Descripción: Actualiza una solicitud de número oficial existente.
-- Generado para formulario: constanciaNoOficialfrm
-- Fecha: 2025-08-27 17:19:01

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