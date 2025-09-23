-- Stored Procedure: dictamenfrm_get_anuncio
-- Tipo: Report
-- Descripción: Obtiene los datos completos de un anuncio para el dictamen, equivalente al query principal del formulario.
-- Generado para formulario: dictamenfrm
-- Fecha: 2025-08-27 17:35:31

CREATE OR REPLACE FUNCTION dictamenfrm_get_anuncio(anuncio_id integer)
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
    SELECT a.*, b.*, c.*,
        TRIM(
            COALESCE(TRIM(b.primer_ap), '') || ' ' ||
            COALESCE(TRIM(b.segundo_ap), '') || ' ' ||
            COALESCE(TRIM(b.propietario), '')
        ) AS propietarionvo
    FROM anuncios a
    JOIN licencias b ON a.id_licencia = b.id_licencia
    JOIN c_giros c ON a.id_giro = c.id_giro
    WHERE a.anuncio = anuncio_id
      AND a.vigente = 'V';
END;
$$ LANGUAGE plpgsql;