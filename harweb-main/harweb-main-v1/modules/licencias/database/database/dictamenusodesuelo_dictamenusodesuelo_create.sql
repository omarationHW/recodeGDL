-- Stored Procedure: dictamenusodesuelo_create
-- Tipo: CRUD
-- Descripción: Crea una nueva constancia/dictamen de uso de suelo
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-27 17:38:15

CREATE OR REPLACE FUNCTION dictamenusodesuelo_create(
  p_solicita VARCHAR,
  p_partidapago VARCHAR,
  p_observacion VARCHAR,
  p_domicilio VARCHAR,
  p_id_licencia INTEGER,
  p_capturista VARCHAR,
  p_tipo INTEGER,
  p_recaud INTEGER DEFAULT NULL,
  p_actividad VARCHAR DEFAULT NULL,
  p_propietario VARCHAR DEFAULT NULL,
  p_ubicacion VARCHAR DEFAULT NULL,
  p_numext_ubic VARCHAR DEFAULT NULL,
  p_letraext_ubic VARCHAR DEFAULT NULL,
  p_numint_ubic VARCHAR DEFAULT NULL,
  p_letraint_ubic VARCHAR DEFAULT NULL,
  p_sup_construida NUMERIC DEFAULT NULL,
  p_sup_autorizada NUMERIC DEFAULT NULL,
  p_num_cajones INTEGER DEFAULT NULL,
  p_num_empleados INTEGER DEFAULT NULL,
  p_vigente VARCHAR DEFAULT 'V',
  p_feccap DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(axo INTEGER, folio INTEGER) AS $$
DECLARE
  nvo_folio INTEGER;
  nvo_axo INTEGER;
BEGIN
  nvo_axo := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
  -- Obtener folio actual
  SELECT constancia + 1 INTO nvo_folio FROM parametros LIMIT 1;
  -- Actualizar folio en parametros
  UPDATE parametros SET constancia = nvo_folio;
  -- Insertar constancia
  INSERT INTO constancias (
    axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, tipo
  ) VALUES (
    nvo_axo, nvo_folio, p_id_licencia, p_solicita, p_partidapago, p_observacion, p_domicilio, p_vigente, p_feccap, p_capturista, p_tipo
  );
  RETURN QUERY SELECT nvo_axo, nvo_folio;
END;
$$ LANGUAGE plpgsql;