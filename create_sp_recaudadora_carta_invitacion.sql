-- Stored Procedure para CartaInvitacion.vue
-- Accede a la tabla cartainvpredial en el esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_carta_invitacion(TEXT, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_carta_invitacion(
    p_clave_cuenta TEXT,
    p_ejercicio INTEGER DEFAULT 0
)
RETURNS TABLE (
    foliocarta TEXT,
    cvecuenta BIGINT,
    cvecatnva TEXT,
    nombre TEXT,
    calle TEXT,
    exterior TEXT,
    colonia TEXT,
    total NUMERIC,
    impuesto NUMERIC,
    axoini INTEGER,
    axofin INTEGER,
    fecemi TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        ci.foliocarta::text,
        ci.cvecuenta::bigint,
        COALESCE(ci.cvecatnva, 'N/A')::text,
        COALESCE(ci.nombre, 'Sin nombre')::text,
        COALESCE(ci.calle, '')::text,
        COALESCE(ci.exterior, '')::text,
        COALESCE(ci.colonia, '')::text,
        COALESCE(ci.total, 0)::numeric,
        COALESCE(ci.impuesto, 0)::numeric,
        ci.axoini::integer,
        ci.axofin::integer,
        COALESCE(ci.fecemi::date::text, '')::text
    FROM public.cartainvpredial ci
    WHERE ci.cvecuenta::text = p_clave_cuenta
      AND ci.vigencia IN ('V', 'A')  -- V=Vigente, A=Activo
      AND (p_ejercicio = 0 OR (ci.axoini <= p_ejercicio AND ci.axofin >= p_ejercicio))
    ORDER BY ci.fecemi DESC, ci.axoini DESC;
END;
$$;
