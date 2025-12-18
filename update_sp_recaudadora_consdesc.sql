-- Actualización del Stored Procedure para consdesc
-- Usa la tabla aut_desctosotorgados del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_consdesc(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_consdesc(
    p_clave_cuenta TEXT DEFAULT ''
)
RETURNS TABLE (
    id_descuento INTEGER,
    clave_cuenta VARCHAR,
    tipo_descuento VARCHAR,
    descripcion TEXT,
    porcentaje_descuento NUMERIC,
    monto_fijo NUMERIC,
    fecha_inicio DATE,
    fecha_fin DATE,
    motivo VARCHAR,
    autorizado_por VARCHAR,
    estado CHARACTER,
    fecha_registro TIMESTAMP,
    observaciones TEXT,
    dias_vigencia INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.folio_descto AS id_descuento,
        TRIM(d.id_multa)::varchar AS clave_cuenta,
        CASE
            WHEN d.tipo_descto = 'P' THEN 'Pronto pago'::varchar
            WHEN d.tipo_descto = 'A' THEN 'Administrativo'::varchar
            WHEN d.tipo_descto = 'E' THEN 'Especial'::varchar
            WHEN d.tipo_descto = 'I' THEN 'Inspección'::varchar
            ELSE COALESCE(d.tipo_descto::varchar, 'Sin especificar')
        END AS tipo_descuento,
        COALESCE(d.datos_descto, 'Sin descripción')::text AS descripcion,
        COALESCE(d.por_aut, 0)::numeric AS porcentaje_descuento,
        COALESCE(d.monto_aut, 0)::numeric AS monto_fijo,
        d.fecha_inicio,
        d.fecha_fin,
        COALESCE(d.motivo, 'Sin motivo')::varchar AS motivo,
        COALESCE(TRIM(d.user_cap), 'SISTEMA')::varchar AS autorizado_por,
        CASE
            WHEN TRIM(d.vigencia) = 'S' THEN 'A'::character
            WHEN TRIM(d.vigencia) = 'V' THEN 'A'::character
            WHEN TRIM(d.vigencia) = 'N' THEN 'I'::character
            WHEN TRIM(d.vigencia) = 'B' THEN 'B'::character
            WHEN TRIM(d.vigencia) = 'C' THEN 'C'::character
            ELSE 'I'::character
        END AS estado,
        COALESCE(d.fecha_act, CURRENT_DATE)::timestamp AS fecha_registro,
        COALESCE(d.motivo, 'Sin observaciones')::text AS observaciones,
        CASE
            WHEN d.fecha_fin IS NOT NULL THEN (d.fecha_fin - CURRENT_DATE)::INTEGER
            ELSE NULL
        END AS dias_vigencia
    FROM public.aut_desctosotorgados d
    WHERE
        TRIM(d.id_multa) = COALESCE(p_clave_cuenta, '')
    ORDER BY d.fecha_act DESC, d.folio_descto DESC;
END;
$$;
