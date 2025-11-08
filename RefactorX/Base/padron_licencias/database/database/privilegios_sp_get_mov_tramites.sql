-- Stored Procedure: sp_get_mov_tramites
-- Tipo: Report
-- Descripción: Obtiene los movimientos de trámites de un usuario en un rango de fechas.
-- Generado para formulario: privilegios
-- Fecha: 2025-08-27 18:54:11

CREATE OR REPLACE FUNCTION sp_get_mov_tramites(
    p_usuario VARCHAR,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    id INTEGER,
    uid SMALLINT,
    username VARCHAR,
    ttyin VARCHAR,
    ttyout VARCHAR,
    ttyerr VARCHAR,
    cwd TEXT,
    hostname TEXT,
    time TIMESTAMP,
    event VARCHAR,
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    x FLOAT,
    y FLOAT,
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
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    espubic VARCHAR,
    documentos TEXT,
    sup_construida FLOAT,
    sup_autorizada FLOAT,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR,
    medidas1 FLOAT,
    medidas2 FLOAT,
    area_anuncio FLOAT,
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
    observaciones TEXT,
    rhorario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM sysbacktram
    WHERE username = p_usuario
      AND DATE(time) BETWEEN p_fechaini AND p_fechafin;
END;
$$ LANGUAGE plpgsql;