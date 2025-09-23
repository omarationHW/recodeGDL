-- Stored Procedure: sp_get_tramite_by_id
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos de un trámite por su ID.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-26 14:42:36

CREATE OR REPLACE FUNCTION sp_get_tramite_by_id(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR(2),
    id_giro INTEGER,
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR(100),
    propietario VARCHAR(80),
    primer_ap VARCHAR(80),
    segundo_ap VARCHAR(80),
    rfc VARCHAR(13),
    curp VARCHAR(18),
    domicilio VARCHAR(50),
    numext_prop INTEGER,
    numint_prop VARCHAR(5),
    colonia_prop VARCHAR(25),
    telefono_prop VARCHAR(30),
    email VARCHAR(50),
    cvecalle INTEGER,
    ubicacion VARCHAR(50),
    numext_ubic INTEGER,
    letraext_ubic VARCHAR(3),
    letrain_ubic VARCHAR(3),
    colonia_ubic VARCHAR(25),
    espubic VARCHAR(60),
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
    texto_anuncio VARCHAR(50),
    medidas1 FLOAT,
    medidas2 FLOAT,
    area_anuncio FLOAT,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR(10),
    estatus VARCHAR(1),
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR(10),
    numint_ubic VARCHAR(5),
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR(50),
    cp INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM tramites WHERE id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;