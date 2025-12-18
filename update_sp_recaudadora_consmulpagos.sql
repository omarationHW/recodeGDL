-- Actualización del Stored Procedure para consmulpagos
-- Usa la tabla pagos del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_consmulpagos(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_consmulpagos(
    p_clave_cuenta TEXT DEFAULT ''
)
RETURNS TABLE (
    id_pago INTEGER,
    clave_cuenta VARCHAR,
    folio_pago VARCHAR,
    fecha_pago DATE,
    monto_pago NUMERIC,
    concepto VARCHAR,
    periodo_fiscal VARCHAR,
    tipo_pago VARCHAR,
    forma_pago VARCHAR,
    referencia_bancaria VARCHAR,
    caja VARCHAR,
    cajero VARCHAR,
    estado CHARACTER,
    fecha_registro TIMESTAMP,
    observaciones TEXT,
    dias_desde_pago INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cvepago AS id_pago,
        p.cvecuenta::varchar AS clave_cuenta,
        CONCAT('FOL-', p.folio)::varchar AS folio_pago,
        p.fecha AS fecha_pago,
        COALESCE(p.importe, 0)::numeric AS monto_pago,
        CASE
            WHEN p.cveconcepto = 1 THEN 'Impuesto predial'
            WHEN p.cveconcepto = 2 THEN 'Multas'
            WHEN p.cveconcepto = 3 THEN 'Licencias'
            WHEN p.cveconcepto = 4 THEN 'Otros'
            ELSE COALESCE('Concepto ' || p.cveconcepto::text, 'Sin concepto')
        END::varchar AS concepto,
        'N/A'::varchar AS periodo_fiscal,
        CASE
            WHEN p.recaud = 1 THEN 'Predial'
            WHEN p.recaud = 2 THEN 'Multas'
            WHEN p.recaud = 3 THEN 'Licencias'
            ELSE COALESCE('Tipo ' || p.recaud::text, 'Sin tipo')
        END::varchar AS tipo_pago,
        'Efectivo'::varchar AS forma_pago,
        'N/A'::varchar AS referencia_bancaria,
        COALESCE(TRIM(p.caja), 'N/A')::varchar AS caja,
        COALESCE(TRIM(p.cajero), 'N/A')::varchar AS cajero,
        CASE
            WHEN p.cvecanc IS NOT NULL AND p.cvecanc > 0 THEN 'C'::character
            ELSE 'A'::character
        END AS estado,
        COALESCE(p.hora, p.fecha::timestamp)::timestamp AS fecha_registro,
        CONCAT('Recaudación: ', p.recaud, ', Concepto: ', COALESCE(p.cveconcepto, 0))::text AS observaciones,
        CASE
            WHEN p.fecha IS NOT NULL THEN (CURRENT_DATE - p.fecha)::INTEGER
            ELSE NULL
        END AS dias_desde_pago
    FROM publico.pagos p
    WHERE
        p.cvecuenta::text = COALESCE(p_clave_cuenta, '')
    ORDER BY p.fecha DESC, p.cvepago DESC;
END;
$$;
