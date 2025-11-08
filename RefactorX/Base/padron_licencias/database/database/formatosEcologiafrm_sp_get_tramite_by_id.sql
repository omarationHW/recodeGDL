-- Stored Procedure: sp_get_tramite_by_id
-- Tipo: Report
-- Descripción: Obtiene los datos completos de un trámite por su ID, incluyendo campos calculados como domcompleto y propietarionvo.
-- Generado para formulario: formatosEcologiafrm
-- Fecha: 2025-08-26 16:29:50

CREATE OR REPLACE FUNCTION sp_get_tramite_by_id(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
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
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
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
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
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
    observaciones TEXT,
    rhorario VARCHAR,
    cp INTEGER,
    domcompleto VARCHAR,
    zona_1 SMALLINT,
    subzona_1 SMALLINT,
    propietarionvo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT *,
        TRIM(COALESCE(ubicacion, '')) || ' No.Ext:' || COALESCE(numext_ubic::TEXT, '') || ' - ' ||
        COALESCE(letraext_ubic, '') || ' No.Int:' || COALESCE(numint_ubic, '') || ' - ' ||
        COALESCE(letraint_ubic, '') || ' CP:' || COALESCE(cp::TEXT, '') AS domcompleto,
        zona, subzona,
        TRIM(TRIM(COALESCE(primer_ap, '')) || ' ' || TRIM(COALESCE(segundo_ap, '')) || ' ' || TRIM(COALESCE(propietario, ''))) AS propietarionvo
    FROM tramites
    WHERE id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;