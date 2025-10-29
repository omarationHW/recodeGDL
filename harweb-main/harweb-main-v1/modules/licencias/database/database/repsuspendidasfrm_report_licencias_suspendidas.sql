-- Stored Procedure: report_licencias_suspendidas
-- Tipo: Report
-- Descripción: Genera el reporte de licencias suspendidas según año, rango de fechas y tipo de suspensión.
-- Generado para formulario: repsuspendidasfrm
-- Fecha: 2025-08-27 19:27:24

CREATE OR REPLACE FUNCTION report_licencias_suspendidas(
    p_year INTEGER DEFAULT 0,
    p_date_from DATE DEFAULT NULL,
    p_date_to DATE DEFAULT NULL,
    p_tipo_suspension INTEGER DEFAULT 0
)
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
    tipo_registro VARCHAR(1),
    actividad VARCHAR(130),
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
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
    numint_ubic VARCHAR(5),
    letraint_ubic VARCHAR(3),
    colonia_ubic VARCHAR(25),
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones INTEGER,
    num_empleados INTEGER,
    aforo INTEGER,
    inversion NUMERIC,
    rhorario VARCHAR(50),
    fecha_consejo DATE,
    bloqueado INTEGER,
    asiento INTEGER,
    vigente VARCHAR(1),
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    espubic VARCHAR(100),
    base_impuesto NUMERIC,
    cp INTEGER,
    propietarionvo VARCHAR(242)
) AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT l.*, ' ||
        'TRIM(COALESCE(TRIM(l.primer_ap), '''') || '' '' || COALESCE(TRIM(l.segundo_ap), '''') || '' '' || TRIM(l.propietario)) AS propietarionvo ' ||
        'FROM licencias l ' ||
        'JOIN bloqueo b ON b.id_licencia = l.id_licencia ' ||
        'WHERE b.vigente = ''V'' ';

    IF p_year > 0 THEN
        v_sql := v_sql || 'AND b.fecha_mov >= ' || quote_literal(p_year::text || '-01-01') || ' ';
    END IF;
    IF p_date_from IS NOT NULL AND p_date_to IS NULL THEN
        v_sql := v_sql || 'AND b.fecha_mov = ' || quote_literal(p_date_from) || ' ';
    ELSIF p_date_from IS NOT NULL AND p_date_to IS NOT NULL THEN
        v_sql := v_sql || 'AND b.fecha_mov >= ' || quote_literal(p_date_from) || ' ';
        v_sql := v_sql || 'AND b.fecha_mov <= ' || quote_literal(p_date_to) || ' ';
    END IF;
    IF p_tipo_suspension > 0 THEN
        v_sql := v_sql || 'AND b.bloqueado = ' || p_tipo_suspension::text || ' ';
    END IF;
    v_sql := v_sql || 'ORDER BY l.licencia';

    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;