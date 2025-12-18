-- Actualización del Stored Procedure para drecgoOtrasObligaciones
-- Usa la tabla pago_diversos del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_drecgootrasobligaciones(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_drecgootrasobligaciones(
    p_clave_cuenta TEXT
)
RETURNS TABLE (
    clave_cuenta VARCHAR,
    tipo_obligacion VARCHAR,
    concepto VARCHAR,
    importe NUMERIC,
    ejercicio INTEGER,
    fecha_vencimiento VARCHAR,
    estatus VARCHAR,
    referencia VARCHAR,
    observaciones VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        pd.cvepago::varchar AS clave_cuenta,
        'Pago Diverso'::varchar AS tipo_obligacion,
        COALESCE(SUBSTRING(pd.concepto, 1, 255), '')::varchar AS concepto,
        0::numeric AS importe,
        COALESCE(pd.axoini, pd.axofin, 0)::integer AS ejercicio,
        CASE
            WHEN pd.axofin IS NOT NULL AND pd.bimfin IS NOT NULL THEN
                CONCAT(pd.axofin, '-', LPAD(pd.bimfin::text, 2, '0'))
            ELSE ''
        END::varchar AS fecha_vencimiento,
        'Registrado'::varchar AS estatus,
        COALESCE(pd.referencia::varchar, '')::varchar AS referencia,
        CONCAT(
            'Contribuyente: ', COALESCE(pd.contribuyente, 'N/A'),
            ' | Domicilio: ', COALESCE(pd.domicilio, 'N/A'),
            ' | Periodo: ', COALESCE(pd.bimini::text, ''), '/', COALESCE(pd.axoini::text, ''),
            ' a ', COALESCE(pd.bimfin::text, ''), '/', COALESCE(pd.axofin::text, '')
        )::varchar AS observaciones
    FROM public.pago_diversos pd
    WHERE
        (p_clave_cuenta = '' OR pd.cvepago::text = p_clave_cuenta OR pd.referencia::text = p_clave_cuenta)
    ORDER BY pd.axoini DESC NULLS LAST, pd.bimini DESC NULLS LAST
    LIMIT 100;
END;
$$;

-- Comentarios sobre el mapeo:
-- cvepago -> clave_cuenta (clave de pago)
-- 'Pago Diverso' -> tipo_obligacion (tipo fijo)
-- concepto -> concepto (descripción del pago)
-- 0 -> importe (no disponible en la tabla)
-- axoini/axofin -> ejercicio (año del pago)
-- bimfin/axofin -> fecha_vencimiento (periodo final en formato año-bimestre)
-- 'Registrado' -> estatus (estado fijo)
-- referencia -> referencia (referencia del pago)
-- contribuyente, domicilio, periodo -> observaciones (información adicional)

-- NOTA: La tabla pago_diversos no tiene todos los campos esperados.
-- Se usan valores por defecto o se construyen a partir de campos disponibles.
