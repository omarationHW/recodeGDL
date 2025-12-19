-- Actualización del Stored Procedure para RegSecyMas.vue
-- Usando tabla ejecutor (ejecutores administrativos)

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_regsecymas'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_regsecymas(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para RegSecyMas (ejecutores administrativos)
CREATE OR REPLACE FUNCTION publico.recaudadora_regsecymas(
    p_busqueda VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje VARCHAR,
    nombre VARCHAR,
    ini_rfc VARCHAR,
    hom_rfc VARCHAR,
    id_rec VARCHAR,
    categoria VARCHAR,
    vigencia VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Usamos tabla ejecutor (ejecutores administrativos)

    RETURN QUERY
    SELECT
        e.cveejecutor::INTEGER AS id_ejecutor,
        e.cveejecutor::VARCHAR AS cve_eje,
        TRIM(
            COALESCE(TRIM(e.paterno), '') || ' ' ||
            COALESCE(TRIM(e.materno), '') || ' ' ||
            COALESCE(TRIM(e.nombres), '')
        )::VARCHAR AS nombre,
        TRIM(e.rfc)::VARCHAR AS ini_rfc,
        TRIM(e.rfc)::VARCHAR AS hom_rfc,
        COALESCE(e.recaud::VARCHAR, '1')::VARCHAR AS id_rec,
        CASE
            WHEN e.vigencia = 'V' THEN 'VIGENTE'
            WHEN e.vigencia = 'C' THEN 'CANCELADO'
            WHEN e.vigencia = 'B' THEN 'BLOQUEADO'
            ELSE 'DESCONOCIDO'
        END::VARCHAR AS categoria,
        CASE
            WHEN e.vigencia = 'V' THEN 'ACTIVO'
            WHEN e.vigencia = 'C' THEN 'INACTIVO'
            WHEN e.vigencia = 'B' THEN 'BLOQUEADO'
            ELSE 'DESCONOCIDO'
        END::VARCHAR AS vigencia
    FROM public.ejecutor e
    WHERE
        CASE
            WHEN p_busqueda = '' OR p_busqueda IS NULL THEN TRUE
            ELSE (
                TRIM(e.paterno || ' ' || e.materno || ' ' || e.nombres) ILIKE '%' || p_busqueda || '%'
                OR e.cveejecutor::VARCHAR ILIKE '%' || p_busqueda || '%'
                OR TRIM(e.rfc) ILIKE '%' || p_busqueda || '%'
                OR e.recaud::VARCHAR ILIKE '%' || p_busqueda || '%'
            )
        END
    ORDER BY e.cveejecutor, e.paterno, e.nombres;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_regsecymas -> Retorna ejecutores administrativos
--
-- TABLA BASE: public.ejecutor (574 registros)
--
-- CAMPOS MAPEADOS:
-- - cveejecutor -> id_ejecutor (ID único del ejecutor)
-- - cveejecutor -> cve_eje (clave del ejecutor)
-- - paterno + materno + nombres -> nombre (nombre completo concatenado)
-- - rfc -> ini_rfc (RFC del ejecutor)
-- - rfc -> hom_rfc (mismo RFC, homologado)
-- - recaud -> id_rec (ID de recaudación)
-- - vigencia -> categoria (V=VIGENTE, C=CANCELADO, B=BLOQUEADO)
-- - vigencia -> vigencia (V=ACTIVO, C=INACTIVO, B=BLOQUEADO)
--
-- PARÁMETROS:
-- - p_busqueda: VARCHAR (búsqueda en nombre, cve_eje, rfc, id_rec)
--
-- ESTADÍSTICAS:
-- - Total registros: 574
-- - Vigentes (V): 471 (82.1%)
-- - Cancelados (C): 86 (15.0%)
-- - Bloqueados (B): 17 (2.9%)
--
-- EJEMPLOS DE USO:
--
-- 1. Buscar todos los ejecutores:
-- SELECT * FROM publico.recaudadora_regsecymas('');
--
-- 2. Buscar por nombre:
-- SELECT * FROM publico.recaudadora_regsecymas('ALBERTO');
--
-- 3. Buscar por RFC:
-- SELECT * FROM publico.recaudadora_regsecymas('AOMA520929');
--
-- 4. Buscar por clave de ejecutor:
-- SELECT * FROM publico.recaudadora_regsecymas('3');
