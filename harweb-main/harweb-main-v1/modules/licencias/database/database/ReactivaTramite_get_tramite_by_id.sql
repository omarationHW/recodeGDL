-- Stored Procedure: get_tramite_by_id
-- Tipo: Catalog
-- Descripción: Obtiene todos los datos de un trámite, incluyendo descripción del giro.
-- Generado para formulario: ReactivaTramite
-- Fecha: 2025-08-26 17:39:04

CREATE OR REPLACE FUNCTION get_tramite_by_id(p_id_tramite integer)
RETURNS TABLE (
    id_tramite integer,
    folio integer,
    tipo_tramite varchar,
    id_giro integer,
    x double precision,
    y double precision,
    zona smallint,
    subzona smallint,
    actividad varchar,
    cvecuenta integer,
    recaud smallint,
    licencia_ref integer,
    tramita_apoderado varchar,
    propietario varchar,
    primer_ap varchar,
    segundo_ap varchar,
    rfc varchar,
    curp varchar,
    domicilio varchar,
    numext_prop integer,
    numint_prop varchar,
    colonia_prop varchar,
    telefono_prop varchar,
    email varchar,
    cvecalle integer,
    ubicacion varchar,
    numext_ubic integer,
    letraext_ubic varchar,
    letrain_ubic varchar,
    colonia_ubic varchar,
    espubic varchar,
    documentos text,
    sup_construida double precision,
    sup_autorizada double precision,
    num_cajones smallint,
    num_empleados smallint,
    aforo smallint,
    inversion numeric,
    costo numeric,
    fecha_consejo date,
    id_fabricante integer,
    texto_anuncio varchar,
    medidas1 double precision,
    medidas2 double precision,
    area_anuncio double precision,
    num_caras smallint,
    calificacion numeric,
    usr_califica varchar,
    estatus varchar,
    id_licencia integer,
    id_anuncio integer,
    feccap date,
    capturista varchar,
    numint_ubic varchar,
    bloqueado smallint,
    dictamen smallint,
    observaciones text,
    rhorario varchar,
    cp integer,
    descripcion_giro varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.*, g.descripcion as descripcion_giro
    FROM tramites t
    LEFT JOIN c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;