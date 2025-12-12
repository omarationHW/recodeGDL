CREATE FUNCTION publico.recaudadora_otorga_descto(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER,
    p_offset INTEGER,
    p_limit INTEGER
)
RETURNS TABLE (
    id_multa INTEGER, folio VARCHAR, anio INTEGER, clave_cuenta VARCHAR,
    contribuyente VARCHAR, domicilio VARCHAR, monto_multa NUMERIC,
    tipo_descto VARCHAR, porcentaje_descto NUMERIC, importe_descto NUMERIC,
    fecha_captura DATE, capturista VARCHAR, autoriza VARCHAR,
    estado VARCHAR, observacion TEXT, total_registros BIGINT
)
LANGUAGE plpgsql AS $$ 
DECLARE
    v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM publico.descuentos_otorgados d
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR d.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR d.anio = p_ejercicio);

    RETURN QUERY
    SELECT d.id_multa, d.folio, d.anio, d.clave_cuenta, d.contribuyente, d.domicilio,
           d.monto_multa, d.tipo_descto, d.porcentaje_descto, d.importe_descto,
           d.fecha_captura, d.capturista, d.autoriza, d.estado, d.observacion,
           v_total AS total_registros
    FROM publico.descuentos_otorgados d
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR d.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR d.anio = p_ejercicio)
    ORDER BY d.fecha_captura DESC, d.id_descuento DESC
    LIMIT p_limit
    OFFSET p_offset;
END; $$;
