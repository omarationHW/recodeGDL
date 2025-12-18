-- Actualización del Stored Procedure para Gastos de Transmisión
-- Usa la tabla reqdiftransmision del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_gastos_transmision(VARCHAR, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_gastos_transmision(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER
)
RETURNS TABLE (
    clave_cuenta VARCHAR,
    concepto VARCHAR,
    importe NUMERIC,
    fecha DATE
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    -- Usar UNION ALL para retornar cada tipo de gasto como un registro separado
    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Impuesto'::VARCHAR AS concepto,
        r.impuesto AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.impuesto IS NOT NULL
        AND r.impuesto > 0

    UNION ALL

    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Recargos'::VARCHAR AS concepto,
        r.recargos AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.recargos IS NOT NULL
        AND r.recargos > 0

    UNION ALL

    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Multa por Impuesto'::VARCHAR AS concepto,
        r.multa_imp AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.multa_imp IS NOT NULL
        AND r.multa_imp > 0

    UNION ALL

    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Multa Extemporánea'::VARCHAR AS concepto,
        r.multa_ext AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.multa_ext IS NOT NULL
        AND r.multa_ext > 0

    UNION ALL

    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Actualización'::VARCHAR AS concepto,
        r.actualizacion AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.actualizacion IS NOT NULL
        AND r.actualizacion > 0

    UNION ALL

    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Gastos'::VARCHAR AS concepto,
        r.gastos AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.gastos IS NOT NULL
        AND r.gastos > 0

    UNION ALL

    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Gastos de Requerimiento'::VARCHAR AS concepto,
        r.gastos_req AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.gastos_req IS NOT NULL
        AND r.gastos_req > 0

    UNION ALL

    SELECT
        r.cvecuenta::VARCHAR AS clave_cuenta,
        'Multa'::VARCHAR AS concepto,
        r.multa AS importe,
        r.fecemi AS fecha
    FROM public.reqdiftransmision r
    WHERE
        (p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        AND r.multa IS NOT NULL
        AND r.multa > 0

    ORDER BY fecha DESC, clave_cuenta, concepto
    LIMIT 200;
END;
$$;

-- Comentarios sobre el mapeo:
-- public.reqdiftransmision -> Vista de gastos
-- cvecuenta -> clave_cuenta (cuenta del contribuyente)
-- Cada tipo de gasto (impuesto, recargos, multas, gastos) se retorna como un registro separado
-- El campo "concepto" identifica el tipo de gasto
-- fecemi -> fecha (fecha de emisión del requerimiento)
-- Solo se incluyen gastos con importe > 0
-- Se ordenan por fecha descendente

-- Tipos de conceptos incluidos:
-- 1. Impuesto
-- 2. Recargos
-- 3. Multa por Impuesto
-- 4. Multa Extemporánea
-- 5. Actualización
-- 6. Gastos
-- 7. Gastos de Requerimiento
-- 8. Multa
