-- Stored Procedure: sp_repestado_get_estado_tramite
-- Tipo: Report
-- Descripción: Obtiene el estado completo de un trámite, incluyendo revisiones y dependencias.
-- Generado para formulario: repestado
-- Fecha: 2025-08-27 19:22:33

-- PostgreSQL stored procedure for repestado
CREATE OR REPLACE FUNCTION sp_repestado_get_estado_tramite(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR(1),
    propietario VARCHAR(80),
    rfc VARCHAR(13),
    curp VARCHAR(18),
    domicilio VARCHAR(50),
    numext_prop INTEGER,
    numint_prop VARCHAR(5),
    colonia_prop VARCHAR(25),
    telefono_prop VARCHAR(30),
    email VARCHAR(50),
    ubicacion VARCHAR(50),
    numext_ubic INTEGER,
    letraext_ubic VARCHAR(3),
    letraint_ubic VARCHAR(3),
    colonia_ubic VARCHAR(25),
    espubic VARCHAR(60),
    documentos TEXT,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    inversion NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR(50),
    medidas1 DOUBLE PRECISION,
    medidas2 DOUBLE PRECISION,
    area_anuncio DOUBLE PRECISION,
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
    tipo_tramite VARCHAR(2),
    observaciones TEXT,
    primer_ap VARCHAR(80),
    segundo_ap VARCHAR(80),
    propietarionvo VARCHAR(242)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id_tramite, t.folio, t.id_giro, t.x, t.y, t.zona, t.subzona, t.actividad, t.cvecuenta, t.recaud, t.licencia_ref, t.tramita_apoderado, t.propietario, t.rfc, t.curp, t.domicilio, t.numext_prop, t.numint_prop, t.colonia_prop, t.telefono_prop, t.email, t.ubicacion, t.numext_ubic, t.letraext_ubic, t.letraint_ubic, t.colonia_ubic, t.espubic, t.documentos, t.sup_construida, t.sup_autorizada, t.num_cajones, t.num_empleados, t.inversion, t.fecha_consejo, t.id_fabricante, t.texto_anuncio, t.medidas1, t.medidas2, t.area_anuncio, t.num_caras, t.calificacion, t.usr_califica, t.estatus, t.id_licencia, t.id_anuncio, t.feccap, t.capturista, t.numint_ubic, t.bloqueado, t.dictamen, t.tipo_tramite, t.observaciones, t.primer_ap, t.segundo_ap, trim(coalesce(t.primer_ap,'') || ' ' || coalesce(t.segundo_ap,'') || ' ' || t.propietario) as propietarionvo
    FROM tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;
