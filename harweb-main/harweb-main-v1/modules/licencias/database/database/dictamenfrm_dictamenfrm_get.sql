-- Stored Procedure: dictamenfrm_get
-- Tipo: Report
-- Descripción: Obtiene los datos del dictamen de anuncio, equivalente al query principal del formulario.
-- Generado para formulario: dictamenfrm
-- Fecha: 2025-08-26 16:05:09

CREATE OR REPLACE FUNCTION dictamenfrm_get(anuncio_in integer)
RETURNS TABLE (
    id_anuncio integer,
    anuncio integer,
    recaud smallint,
    id_giro integer,
    id_licencia integer,
    fecha_otorgamiento date,
    misma_forma varchar,
    medidas1 double precision,
    medidas2 double precision,
    area_anuncio double precision,
    num_caras smallint,
    ubicacion varchar,
    numext_ubic integer,
    letraext_ubic varchar,
    numint_ubic varchar,
    letraint_ubic varchar,
    colonia_ubic varchar,
    id_fabricante integer,
    texto_anuncio varchar,
    asiento smallint,
    vigente varchar,
    espubic varchar,
    fecha_baja date,
    axo_baja integer,
    folio_baja integer,
    id_licencia_1 integer,
    licencia integer,
    empresa integer,
    recaud_1 smallint,
    id_giro_1 integer,
    x double precision,
    y double precision,
    tipo_registro varchar,
    actividad varchar,
    cvecuenta integer,
    fecha_otorgamiento_1 date,
    propietario varchar,
    rfc varchar,
    curp varchar,
    domicilio varchar,
    numext_prop integer,
    numint_prop varchar,
    colonia_prop varchar,
    telefono_prop varchar,
    email varchar,
    ubicacion_1 varchar,
    numext_ubic_1 integer,
    letraext_ubic_1 varchar,
    numint_ubic_1 varchar,
    letraint_ubic_1 varchar,
    colonia_ubic_1 varchar,
    sup_construida double precision,
    sup_autorizada double precision,
    num_cajones smallint,
    num_empleados smallint,
    fecha_consejo date,
    bloqueado smallint,
    asiento_1 smallint,
    vigente_1 varchar,
    fecha_baja_1 date,
    axo_baja_1 integer,
    folio_baja_1 integer,
    espubic_1 varchar,
    id_giro_2 integer,
    cod_giro integer,
    cod_anun varchar,
    descripcion varchar,
    caracteristicas varchar,
    clasificacion varchar,
    tipo varchar,
    ctaaplic integer,
    reglamentada varchar,
    cp integer,
    propietarionvo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_anuncio, a.anuncio, a.recaud, a.id_giro, a.id_licencia, a.fecha_otorgamiento, a.misma_forma, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic, a.id_fabricante, a.texto_anuncio, a.asiento, a.vigente, a.espubic, a.fecha_baja, a.axo_baja, a.folio_baja,
        b.id_licencia as id_licencia_1, b.licencia, b.empresa, b.recaud as recaud_1, b.id_giro as id_giro_1, b.x, b.y, b.tipo_registro, b.actividad, b.cvecuenta, b.fecha_otorgamiento as fecha_otorgamiento_1, b.propietario, b.rfc, b.curp, b.domicilio, b.numext_prop, b.numint_prop, b.colonia_prop, b.telefono_prop, b.email, b.ubicacion as ubicacion_1, b.numext_ubic as numext_ubic_1, b.letraext_ubic as letraext_ubic_1, b.numint_ubic as numint_ubic_1, b.letraint_ubic as letraint_ubic_1, b.colonia_ubic as colonia_ubic_1, b.sup_construida, b.sup_autorizada, b.num_cajones, b.num_empleados, b.fecha_consejo, b.bloqueado, b.asiento as asiento_1, b.vigente as vigente_1, b.fecha_baja as fecha_baja_1, b.axo_baja as axo_baja_1, b.folio_baja as folio_baja_1, b.espubic as espubic_1,
        c.id_giro as id_giro_2, c.cod_giro, c.cod_anun, c.descripcion, c.caracteristicas, c.clasificacion, c.tipo, c.ctaaplic, c.reglamentada,
        a.cp,
        trim(coalesce(b.primer_ap,'') || ' ' || coalesce(b.segundo_ap,'') || ' ' || coalesce(b.propietario,'')) as propietarionvo
    FROM anuncios a
    JOIN licencias b ON a.id_licencia = b.id_licencia
    JOIN c_giros c ON a.id_giro = c.id_giro
    WHERE a.anuncio = anuncio_in AND a.vigente = 'V';
END;
$$ LANGUAGE plpgsql;