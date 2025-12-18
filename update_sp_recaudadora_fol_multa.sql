-- Actualización del Stored Procedure para FolMulta
-- Usa la tabla multas del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_fol_multa(VARCHAR, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_fol_multa(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER DEFAULT 0
)
RETURNS TABLE (
    folio VARCHAR,
    numero_acta VARCHAR,
    axo_acta INTEGER,
    estado VARCHAR,
    nombre VARCHAR,
    domicilio VARCHAR,
    actividad_giro VARCHAR,
    numero_licencia VARCHAR,
    importe_inicial DECIMAL,
    importe_pagar DECIMAL,
    importe_pago DECIMAL,
    fecha_alta DATE,
    fecha_recepcion DATE,
    fecha_pago DATE,
    sector VARCHAR,
    numero_zona VARCHAR,
    sub_zona VARCHAR,
    recaudadora VARCHAR,
    operacion VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.id_multa::varchar AS folio,
        m.num_acta::varchar AS numero_acta,
        m.axo_acta::integer AS axo_acta,
        CASE
            WHEN m.cvepago IS NOT NULL AND m.cvepago > 0 THEN 'PAGADA'
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'CANCELADA'
            WHEN m.fecha_plazo IS NOT NULL AND m.fecha_plazo < CURRENT_DATE THEN 'VENCIDA'
            ELSE 'VIGENTE'
        END::varchar AS estado,
        COALESCE(TRIM(m.contribuyente), 'SIN NOMBRE')::varchar AS nombre,
        COALESCE(
            TRIM(m.domicilio) ||
            CASE WHEN m.noexterior IS NOT NULL AND TRIM(m.noexterior) != '' THEN ' #' || TRIM(m.noexterior) ELSE '' END ||
            CASE WHEN m.interior IS NOT NULL AND TRIM(m.interior) != '' THEN ' INT ' || TRIM(m.interior) ELSE '' END,
            'SIN DOMICILIO'
        )::varchar AS domicilio,
        COALESCE(TRIM(m.giro), 'SIN GIRO')::varchar AS actividad_giro,
        COALESCE(m.num_licencia::varchar, '')::varchar AS numero_licencia,
        COALESCE(m.multa, 0)::decimal AS importe_inicial,
        COALESCE(m.total, m.multa, 0)::decimal AS importe_pagar,
        COALESCE(
            CASE WHEN m.cvepago IS NOT NULL AND m.cvepago > 0 THEN m.total ELSE 0 END,
            0
        )::decimal AS importe_pago,
        m.fecha_acta AS fecha_alta,
        m.fecha_recepcion,
        CASE
            WHEN m.cvepago IS NOT NULL AND m.cvepago > 0 THEN m.fecha_recepcion
            ELSE NULL
        END AS fecha_pago,
        CASE
            WHEN m.id_dependencia = 1 THEN 'SECTOR 1'
            WHEN m.id_dependencia = 2 THEN 'SECTOR 2'
            WHEN m.id_dependencia = 3 THEN 'SECTOR 3'
            ELSE 'OTRO SECTOR'
        END::varchar AS sector,
        COALESCE(m.zona::varchar, '0')::varchar AS numero_zona,
        COALESCE(m.subzona::varchar, '0')::varchar AS sub_zona,
        CASE
            WHEN m.recaud = 1 THEN 'RECAUDACION PREDIAL'
            WHEN m.recaud = 2 THEN 'RECAUDACION MUNICIPAL'
            WHEN m.recaud = 3 THEN 'MULTAS'
            WHEN m.recaud = 4 THEN 'LICENCIAS'
            ELSE 'OTRAS'
        END::varchar AS recaudadora,
        COALESCE(m.expediente, '')::varchar AS operacion
    FROM publico.multas m
    WHERE
        m.num_acta::text = p_clave_cuenta
        AND (p_ejercicio = 0 OR m.axo_acta = p_ejercicio)
    ORDER BY
        m.id_multa
    LIMIT 100;
END;
$$;

-- Comentarios sobre el mapeo:
-- multas.id_multa -> folio (ID único de la multa)
-- multas.num_acta -> numero_acta (número de acta)
-- multas.axo_acta -> axo_acta (año del acta)
-- multas.cvepago + fecha_cancelacion -> estado (PAGADA, CANCELADA, VENCIDA, VIGENTE)
-- multas.contribuyente -> nombre (nombre del contribuyente)
-- multas.domicilio + noexterior + interior -> domicilio (dirección completa)
-- multas.giro -> actividad_giro (actividad o giro comercial)
-- multas.num_licencia -> numero_licencia
-- multas.multa -> importe_inicial (monto original de la multa)
-- multas.total -> importe_pagar (monto total a pagar)
-- multas.cvepago -> determina importe_pago (si está pagada)
-- multas.fecha_acta -> fecha_alta
-- multas.fecha_recepcion -> fecha_recepcion
-- multas.id_dependencia -> sector
-- multas.zona -> numero_zona
-- multas.subzona -> sub_zona
-- multas.recaud -> recaudadora (1=Predial, 2=Municipal, 3=Multas, 4=Licencias)
-- multas.expediente -> operacion
