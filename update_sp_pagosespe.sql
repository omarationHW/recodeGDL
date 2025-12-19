-- Actualización del Stored Procedure para PagosEspe.vue
-- Usa la tabla existente: public.autpagoesp

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_pagos_espe'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_pagos_espe(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para PagosEspe con paginación
CREATE OR REPLACE FUNCTION publico.recaudadora_pagos_espe(
    p_clave_cuenta VARCHAR DEFAULT '',
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cveaut INTEGER,
    cvecuenta VARCHAR,
    bimestre_inicio SMALLINT,
    año_inicio SMALLINT,
    bimestre_fin SMALLINT,
    año_fin SMALLINT,
    fecha_autorizacion DATE,
    autorizado_por VARCHAR,
    cve_pago INTEGER,
    estado VARCHAR,
    monto_autorizado NUMERIC,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cveaut,
        COALESCE(p.cvecuenta::VARCHAR, '')::VARCHAR AS cvecuenta,
        COALESCE(p.bimini, 0)::SMALLINT AS bimestre_inicio,
        COALESCE(p.axoini, 0)::SMALLINT AS año_inicio,
        COALESCE(p.bimfin, 0)::SMALLINT AS bimestre_fin,
        COALESCE(p.axofin, 0)::SMALLINT AS año_fin,
        p.fecaut AS fecha_autorizacion,
        TRIM(COALESCE(p.autorizo, ''))::VARCHAR AS autorizado_por,
        COALESCE(p.cvepago, 0)::INTEGER AS cve_pago,
        'Autorizado'::VARCHAR AS estado,
        0::NUMERIC AS monto_autorizado,
        ''::TEXT AS observaciones
    FROM public.autpagoesp p
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR p.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio IS NULL OR p.axoini = p_ejercicio OR p.axofin = p_ejercicio)
    ORDER BY p.fecaut DESC, p.cveaut DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.autpagoesp -> Tabla de autorizaciones de pagos especiales
--
-- Mapeo de campos:
-- cveaut → cveaut (clave de autorización - identificador único)
-- cvecuenta → cvecuenta (clave de cuenta)
-- bimestre_inicio → bimini (bimestre inicial)
-- año_inicio → axoini (año inicial)
-- bimestre_fin → bimfin (bimestre final)
-- año_fin → axofin (año final)
-- fecha_autorizacion → fecaut (fecha de autorización)
-- autorizado_por → autorizo (quien autorizó)
-- cve_pago → cvepago (clave de pago)
-- estado → 'Autorizado' (todos los registros son autorizaciones, campo derivado)
-- monto_autorizado → 0 (no existe en tabla, retorna 0)
-- observaciones → '' (no existe en tabla, retorna vacío)
--
-- BÚSQUEDA:
-- El filtro p_clave_cuenta busca en:
-- - cvecuenta (clave de cuenta)
--
-- El filtro p_ejercicio busca en:
-- - axoini (año inicial)
-- - axofin (año final)
--
-- IMPORTANTE:
-- - Búsqueda con ILIKE (case-insensitive)
-- - Límite de 100 registros por consulta
-- - Ordenamiento: fecha de autorización descendente
-- - estado siempre es 'Autorizado' (son autorizaciones de pagos)
-- - monto_autorizado no disponible en tabla (retorna 0)
-- - observaciones no disponible en tabla (retorna vacío)
-- - Bimestres van de 1 a 6 (Ene-Feb, Mar-Abr, May-Jun, Jul-Ago, Sep-Oct, Nov-Dic)
--
-- ESTADÍSTICAS:
-- Total autorizaciones: 3,728
-- Años: principalmente 1997-1999
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_pagos_espe('', NULL);  -- Últimas 100 autorizaciones
-- SELECT * FROM publico.recaudadora_pagos_espe('104241', NULL);  -- Buscar por cuenta
-- SELECT * FROM publico.recaudadora_pagos_espe('', 1999);  -- Buscar por año
-- SELECT * FROM publico.recaudadora_pagos_espe('104241', 1999);  -- Ambos filtros
