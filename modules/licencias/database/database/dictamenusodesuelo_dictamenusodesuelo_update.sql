-- Stored Procedure: dictamenusodesuelo_update
-- Tipo: CRUD
-- Descripción: Actualiza una constancia existente
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-27 17:38:15

CREATE OR REPLACE FUNCTION dictamenusodesuelo_update(
  p_axo INTEGER,
  p_folio INTEGER,
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
  p_vigente VARCHAR DEFAULT 'V'
)
RETURNS VOID AS $$
BEGIN
  UPDATE constancias SET
    solicita = p_solicita,
    partidapago = p_partidapago,
    observacion = p_observacion,
    domicilio = p_domicilio,
    id_licencia = p_id_licencia,
    capturista = p_capturista,
    tipo = p_tipo,
    vigente = p_vigente
  WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;