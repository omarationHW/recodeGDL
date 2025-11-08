-- Stored Procedure: sp_get_tramite_by_id
-- Tipo: Catalog
-- Descripción: Obtiene todos los datos de un trámite por su id_tramite.
-- Generado para formulario: cancelaTramitefrm
-- Fecha: 2025-08-27 16:33:29

CREATE OR REPLACE FUNCTION sp_get_tramite_by_id(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR(2),
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR(100),
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
    letraint_ubic VARCHAR(3),
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
    cp INTEGER,
    id_giro INTEGER,
    propietario VARCHAR(80),
    primer_ap VARCHAR(80),
    segundo_ap VARCHAR(80)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id_tramite, t.folio, t.tipo_tramite, t.x, t.y, t.zona, t.subzona, t.actividad, t.cvecuenta, t.recaud, t.licencia_ref,
        t.tramita_apoderado, t.rfc, t.curp, t.domicilio, t.numext_prop, t.numint_prop, t.colonia_prop, t.telefono_prop, t.email,
        t.cvecalle, t.ubicacion, t.numext_ubic, t.letraext_ubic, t.letraint_ubic, t.colonia_ubic, t.espubic, t.documentos,
        t.sup_construida, t.sup_autorizada, t.num_cajones, t.num_empleados, t.aforo, t.inversion, t.costo, t.fecha_consejo,
        t.id_fabricante, t.texto_anuncio, t.medidas1, t.medidas2, t.area_anuncio, t.num_caras, t.calificacion, t.usr_califica,
        t.estatus, t.id_licencia, t.id_anuncio, t.feccap, t.capturista, t.numint_ubic, t.bloqueado, t.dictamen, t.observaciones,
        t.rhorario, t.cp, t.id_giro, t.propietario, t.primer_ap, t.segundo_ap
    FROM tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;