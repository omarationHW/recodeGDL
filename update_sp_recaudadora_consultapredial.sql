-- Actualización del Stored Procedure para consultapredial
-- Usa la tabla cartainvpredial del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_consultapredial(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_consultapredial(
    p_cvecat TEXT DEFAULT ''
)
RETURNS TABLE (
    id_predio INTEGER,
    cvecatnva VARCHAR,
    cvecuenta VARCHAR,
    vigente CHARACTER,
    urbano_rustico CHARACTER,
    val_fiscal NUMERIC,
    saldo NUMERIC,
    axoadeudo VARCHAR,
    exenta CHARACTER,
    area_terreno NUMERIC,
    area_construccion NUMERIC,
    tipo_predio VARCHAR,
    bloqueado CHARACTER,
    fecha_registro TIMESTAMP,
    fecha_actualizacion TIMESTAMP
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cvereq AS id_predio,
        COALESCE(p.cvecatnva, '')::varchar AS cvecatnva,
        p.cvecuenta::varchar AS cvecuenta,
        p.vigencia AS vigente,
        CASE
            WHEN p.recaud = 1 THEN 'U'::character
            WHEN p.recaud = 2 THEN 'R'::character
            ELSE 'U'::character
        END AS urbano_rustico,
        COALESCE(p.impuesto, 0)::numeric AS val_fiscal,
        COALESCE(p.total, 0)::numeric AS saldo,
        CONCAT(p.axoini, '-', p.axofin)::varchar AS axoadeudo,
        'N'::character AS exenta,
        0::numeric AS area_terreno,
        0::numeric AS area_construccion,
        'Carta invitación'::varchar AS tipo_predio,
        CASE
            WHEN p.vigencia = 'V' THEN 'N'::character
            ELSE 'S'::character
        END AS bloqueado,
        COALESCE(p.feccap, p.fecemi)::timestamp AS fecha_registro,
        p.fecejec::timestamp AS fecha_actualizacion
    FROM public.cartainvpredial p
    WHERE
        COALESCE(p.cvecatnva, '') = COALESCE(p_cvecat, '')
    LIMIT 1;
END;
$$;
