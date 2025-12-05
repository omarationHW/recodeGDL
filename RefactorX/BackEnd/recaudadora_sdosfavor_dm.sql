CREATE OR REPLACE FUNCTION recaudadora_sdosfavor_dm(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvecuenta INTEGER,
    id_convenio INTEGER,
    folio TEXT,
    saldo_inicial NUMERIC(12,2),
    importe_aplicado NUMERIC(12,2),
    saldo_restante NUMERIC(12,2),
    fecha_alta DATE,
    fecha_cancelacion DATE,
    usuario_alta TEXT,
    usuario_cancelacion TEXT,
    estado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.cvecuenta,
        s.id_convenio,
        TRIM(s.folio)::TEXT as folio,
        s.saldoinicial as saldo_inicial,
        s.importeaplicado as importe_aplicado,
        (s.saldoinicial - s.importeaplicado) as saldo_restante,
        s.fechaalta as fecha_alta,
        s.fechacan as fecha_cancelacion,
        TRIM(s.usu_alta)::TEXT as usuario_alta,
        TRIM(s.usu_can)::TEXT as usuario_cancelacion,
        CASE
            WHEN s.fechacan IS NOT NULL THEN 'Cancelado'::TEXT
            WHEN (s.saldoinicial - s.importeaplicado) > 0 THEN 'Pendiente'::TEXT
            WHEN (s.saldoinicial - s.importeaplicado) = 0 THEN 'Liquidado'::TEXT
            ELSE 'Aplicado'::TEXT
        END as estado
    FROM catastro_gdl.saldosafavor s
    WHERE (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR s.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
    ORDER BY s.cvecuenta DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
