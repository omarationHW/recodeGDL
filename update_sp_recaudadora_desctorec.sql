-- Actualización del Stored Procedure para desctorec
-- Usa la tabla descrec del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_desctorec(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_desctorec(
    p_cvecuenta VARCHAR
)
RETURNS TABLE (
    cvecuenta VARCHAR,
    axoini INTEGER,
    bimini INTEGER,
    axofin INTEGER,
    bimfin INTEGER,
    porcentaje NUMERIC,
    fecalta DATE,
    captalta VARCHAR,
    vigencia VARCHAR,
    vigencia_desc VARCHAR,
    fecbaja DATE,
    captbaja VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.cvecuenta::varchar AS cvecuenta,
        d.axoini::integer AS axoini,
        d.bimini::integer AS bimini,
        d.axofin::integer AS axofin,
        d.bimfin::integer AS bimfin,
        d.porcentaje::numeric AS porcentaje,
        d.fecalta,
        COALESCE(TRIM(d.captalta), '')::varchar AS captalta,
        COALESCE(d.vigencia, '')::varchar AS vigencia,
        CASE
            WHEN d.vigencia = 'V' THEN 'Vigente'::varchar
            WHEN d.vigencia = 'C' THEN 'Cancelado'::varchar
            WHEN d.vigencia = 'P' THEN 'Pendiente'::varchar
            WHEN d.vigencia IS NULL THEN 'Sin status'::varchar
            ELSE 'Desconocido'::varchar
        END AS vigencia_desc,
        d.fecbaja,
        COALESCE(TRIM(d.captbaja), '')::varchar AS captbaja
    FROM public.descrec d
    WHERE
        d.cvecuenta::text = p_cvecuenta
    ORDER BY d.fecalta DESC, d.axoini DESC, d.bimini DESC
    LIMIT 100;
END;
$$;

-- Comentarios sobre el mapeo:
-- descrec.cvecuenta -> cvecuenta (cuenta predial)
-- descrec.axoini -> axoini (año inicial del descuento)
-- descrec.bimini -> bimini (bimestre inicial)
-- descrec.axofin -> axofin (año final del descuento)
-- descrec.bimfin -> bimfin (bimestre final)
-- descrec.porcentaje -> porcentaje (porcentaje de descuento en recargos)
-- descrec.fecalta -> fecalta (fecha de alta)
-- descrec.captalta -> captalta (capturista)
-- descrec.vigencia -> vigencia (V=Vigente, C=Cancelado, P=Pendiente)
-- descrec.fecbaja -> fecbaja (fecha de baja/cancelación)
-- descrec.captbaja -> captbaja (capturista que canceló)
