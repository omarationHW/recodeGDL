-- Stored Procedure para bloqctasreqfrm.vue
-- Accede a la tabla norequeriblemul en el esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_bloqctasreqfrm(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_bloqctasreqfrm(
    p_clave_cuenta TEXT
)
RETURNS TABLE (
    cuenta TEXT,
    fecha_bloqueo TIMESTAMP,
    motivo TEXT,
    usuario TEXT,
    estatus TEXT,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        nm.id_multa::text AS cuenta,
        COALESCE(nm.feccap, CURRENT_DATE)::timestamp AS fecha_bloqueo,
        CASE
            WHEN nm.tipo_bloq = 1 THEN 'Suspensión provisional'
            WHEN nm.tipo_bloq = 2 THEN 'Bloqueo administrativo'
            WHEN nm.tipo_bloq = 3 THEN 'Bloqueo judicial'
            WHEN nm.tipo_bloq = 200 THEN 'No requerible'
            ELSE 'Bloqueo tipo ' || COALESCE(nm.tipo_bloq::text, 'desconocido')
        END::text AS motivo,
        COALESCE(TRIM(nm.capturista), 'SISTEMA')::text AS usuario,
        CASE
            WHEN nm.fecbaja IS NOT NULL THEN 'INACTIVO'
            ELSE 'ACTIVO'
        END::text AS estatus,
        COALESCE(nm.observacion, 'Sin observaciones')::text AS observaciones
    FROM public.norequeriblemul nm
    WHERE nm.id_multa::text = p_clave_cuenta
    ORDER BY nm.feccap DESC;
END;
$$;
