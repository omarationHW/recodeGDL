-- Stored Procedure: sp_buscar_licencia
-- Tipo: Catalog
-- Descripción: Busca una licencia vigente por número y retorna los datos completos, incluyendo domicilio y nombre completo.
-- Generado para formulario: ImpRecibofrm
-- Fecha: 2025-08-26 17:05:07

CREATE OR REPLACE FUNCTION sp_buscar_licencia(p_licencia INTEGER)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud INTEGER,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona INTEGER,
    subzona INTEGER,
    tipo_registro VARCHAR,
    actividad VARCHAR,
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
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
    numint_ubic VARCHAR,
    letrain_ubic VARCHAR,
    colonia_ubic VARCHAR,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones INTEGER,
    num_empleados INTEGER,
    aforo INTEGER,
    inversion NUMERIC,
    rhorario VARCHAR,
    fecha_consejo DATE,
    bloqueado INTEGER,
    asiento INTEGER,
    vigente VARCHAR,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    espubic VARCHAR,
    base_impuesto NUMERIC,
    cp INTEGER,
    dom_completo VARCHAR,
    propietarionvo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT *,
        (ubicacion || ' ' || COALESCE(numext_ubic::text,'') || '-' || COALESCE(letraext_ubic,'') || '-' || COALESCE(numint_ubic,'') || '-' || COALESCE(letraint_ubic,'')) AS dom_completo,
        (COALESCE(primer_ap,'') || ' ' || COALESCE(segundo_ap,'') || ' ' || COALESCE(propietario,'')) AS propietarionvo
    FROM licencias
    WHERE licencia = p_licencia AND vigente = 'V';
END;
$$ LANGUAGE plpgsql;