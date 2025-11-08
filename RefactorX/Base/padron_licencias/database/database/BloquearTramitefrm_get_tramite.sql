-- Stored Procedure: get_tramite
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos de un trámite por su id_tramite.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-27 16:06:44

CREATE OR REPLACE FUNCTION get_tramite(p_id_tramite integer)
RETURNS TABLE (
    id_tramite integer,
    folio integer,
    tipo_tramite varchar,
    id_giro integer,
    x float,
    y float,
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
    letraint_ubic varchar,
    colonia_ubic varchar,
    espubic varchar,
    documentos text,
    sup_construida float,
    sup_autorizada float,
    num_cajones smallint,
    num_empleados smallint,
    aforo smallint,
    inversion numeric,
    costo numeric,
    fecha_consejo date,
    id_fabricante integer,
    texto_anuncio varchar,
    medidas1 float,
    medidas2 float,
    area_anuncio float,
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
    cp integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM tramites WHERE id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;