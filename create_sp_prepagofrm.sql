CREATE OR REPLACE FUNCTION publico.recaudadora_prepagofrm(
    p_busqueda VARCHAR
)
RETURNS TABLE (
    cvepago VARCHAR,
    cvecuenta VARCHAR,
    folio VARCHAR,
    fecha_pago DATE,
    importe NUMERIC,
    caja VARCHAR,
    cajero VARCHAR,
    cancelado VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cvepago,
        p.cvecuenta,
        p.folio,
        p.fecha_pago,
        p.importe,
        p.caja,
        p.cajero,
        p.cancelado
    FROM publico.prepagos p
    WHERE
        CASE
            WHEN p_busqueda = '' OR p_busqueda IS NULL THEN TRUE
            ELSE (
                p.cvepago ILIKE '%' || p_busqueda || '%'
                OR p.cvecuenta ILIKE '%' || p_busqueda || '%'
                OR p.folio ILIKE '%' || p_busqueda || '%'
            )
        END
    ORDER BY p.fecha_pago DESC, p.id_prepago DESC
    LIMIT 100;
END; $$;
