-- ============================================
-- DEPLOY CONSOLIDADO: repsuspendidasfrm
-- Componente 84/95 - BATCH 17
-- Generado: 2025-11-20
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_report_licencias_suspendidas
CREATE OR REPLACE FUNCTION public.sp_report_licencias_suspendidas(
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
    letraint_ubic VARCHAR,
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
    propietarionvo VARCHAR
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
