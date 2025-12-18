-- Actualización del Stored Procedure para descpredfrm
-- Usa las tablas descpred y c_descpred del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_descpredfrm(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_descpredfrm(
    p_cvecat VARCHAR
)
RETURNS TABLE (
    cvecuenta VARCHAR,
    cvedescuento VARCHAR,
    descripcion VARCHAR,
    porcentaje NUMERIC,
    ejercicio INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    fecalta DATE,
    captalta VARCHAR,
    status INTEGER,
    status_desc VARCHAR,
    solicitante VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.cvecuenta::varchar AS cvecuenta,
        d.cvedescuento::varchar AS cvedescuento,
        COALESCE(TRIM(c.descripcion), 'Descuento sin descripción')::varchar AS descripcion,
        COALESCE(c.porcentaje, 0)::numeric AS porcentaje,
        COALESCE(c.axodescto, 0)::integer AS ejercicio,
        d.bimini::integer AS bimini,
        d.bimfin::integer AS bimfin,
        d.fecalta,
        COALESCE(TRIM(d.captalta), '')::varchar AS captalta,
        CASE
            WHEN d.status = 'V' THEN 1
            WHEN d.status = 'C' THEN 0
            WHEN d.status = 'A' THEN 2
            ELSE 0
        END AS status,
        CASE
            WHEN d.status = 'V' THEN 'Vigente'::varchar
            WHEN d.status = 'C' THEN 'Cancelado'::varchar
            WHEN d.status = 'A' THEN 'Activo'::varchar
            WHEN d.status IS NULL THEN 'Sin status'::varchar
            ELSE 'Desconocido'::varchar
        END AS status_desc,
        COALESCE(TRIM(d.solicitante), '')::varchar AS solicitante,
        COALESCE(d.observaciones, '')::text AS observaciones
    FROM public.descpred d
    LEFT JOIN public.c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE
        d.cvecuenta::text = p_cvecat
    ORDER BY d.fecalta DESC, d.bimini DESC
    LIMIT 100;
END;
$$;

-- Comentarios sobre el mapeo:
-- descpred.cvecuenta -> cvecuenta (cuenta predial)
-- descpred.cvedescuento -> cvedescuento (código del descuento)
-- c_descpred.descripcion -> descripcion (descripción del tipo de descuento)
-- c_descpred.porcentaje -> porcentaje (porcentaje del descuento)
-- c_descpred.axodescto -> ejercicio (año del descuento)
-- descpred.bimini -> bimini (bimestre inicial)
-- descpred.bimfin -> bimfin (bimestre final)
-- descpred.fecalta -> fecalta (fecha de alta)
-- descpred.captalta -> captalta (capturista)
-- descpred.status -> status (V=Vigente, C=Cancelado, A=Activo)
-- descpred.solicitante -> solicitante
-- descpred.observaciones -> observaciones
