-- Stored Procedure: sp_get_tramite_estado
-- Tipo: Report
-- Descripción: Obtiene los datos principales del trámite y el nombre completo del propietario.
-- Generado para formulario: repestado
-- Fecha: 2025-08-26 17:55:36

CREATE OR REPLACE FUNCTION sp_get_tramite_estado(p_id_tramite INTEGER)
RETURNS TABLE (
  id_tramite INTEGER,
  folio INTEGER,
  id_giro INTEGER,
  x DOUBLE PRECISION,
  y DOUBLE PRECISION,
  zona SMALLINT,
  subzona SMALLINT,
  actividad VARCHAR,
  cvecuenta INTEGER,
  recaud SMALLINT,
  licencia_ref INTEGER,
  tramita_apoderado VARCHAR,
  propietario VARCHAR,
  rfc VARCHAR,
  curp VARCHAR,
  domicilio VARCHAR,
  numext_prop INTEGER,
  numint_prop VARCHAR,
  colonia_prop VARCHAR,
  telefono_prop VARCHAR,
  email VARCHAR,
  ubicacion VARCHAR,
  numext_ubic INTEGER,
  letraext_ubic VARCHAR,
  letraint_ubic VARCHAR,
  colonia_ubic VARCHAR,
  espubic VARCHAR,
  documentos TEXT,
  sup_construida DOUBLE PRECISION,
  sup_autorizada DOUBLE PRECISION,
  num_cajones SMALLINT,
  num_empleados SMALLINT,
  inversion NUMERIC,
  fecha_consejo DATE,
  id_fabricante INTEGER,
  texto_anuncio VARCHAR,
  medidas1 DOUBLE PRECISION,
  medidas2 DOUBLE PRECISION,
  area_anuncio DOUBLE PRECISION,
  num_caras SMALLINT,
  calificacion NUMERIC,
  usr_califica VARCHAR,
  estatus VARCHAR,
  id_licencia INTEGER,
  id_anuncio INTEGER,
  feccap DATE,
  capturista VARCHAR,
  numint_ubic VARCHAR,
  bloqueado SMALLINT,
  dictamen SMALLINT,
  tipo_tramite VARCHAR,
  observaciones TEXT,
  primer_ap VARCHAR,
  segundo_ap VARCHAR,
  propietarionvo VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT t.*, t.tipo_tramite, t.observaciones, t.primer_ap, t.segundo_ap,
    TRIM(COALESCE(t.primer_ap,'') || ' ' || COALESCE(t.segundo_ap,'') || ' ' || COALESCE(t.propietario,'')) AS propietarionvo
  FROM tramites t
  WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;