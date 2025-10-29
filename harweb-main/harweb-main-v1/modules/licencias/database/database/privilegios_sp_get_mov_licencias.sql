-- Stored Procedure: sp_get_mov_licencias
-- Tipo: Report
-- Descripción: Obtiene los movimientos de licencias de un usuario en un rango de fechas.
-- Generado para formulario: privilegios
-- Fecha: 2025-08-27 18:54:11

CREATE OR REPLACE FUNCTION sp_get_mov_licencias(
    p_usuario VARCHAR,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    id INTEGER,
    uid INTEGER,
    username VARCHAR,
    ttyin VARCHAR,
    ttyout VARCHAR,
    ttyerr VARCHAR,
    cwd TEXT,
    hostname TEXT,
    time TIMESTAMP,
    event VARCHAR,
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    tipo_registro VARCHAR,
    actividad VARCHAR,
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
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
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    sup_construida FLOAT,
    sup_autorizada FLOAT,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    rhorario VARCHAR,
    fecha_consejo DATE,
    bloqueado SMALLINT,
    asiento SMALLINT,
    vigente VARCHAR,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    espubic VARCHAR,
    base_impuesto NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM get_sysbacklcs(p_usuario, p_fechaini, p_fechafin);
END;
$$ LANGUAGE plpgsql;