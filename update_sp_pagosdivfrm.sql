-- Actualización del Stored Procedure para pagosdivfrm.vue
-- Usa la tabla existente: public.pago_diversos

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_pagosdivfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_pagosdivfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para pagosdivfrm
CREATE OR REPLACE FUNCTION publico.recaudadora_pagosdivfrm(
    p_clave_cuenta VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_pago INTEGER,
    clave_cuenta VARCHAR,
    folio_pago VARCHAR,
    fecha_pago TEXT,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    concepto TEXT,
    monto NUMERIC,
    forma_pago VARCHAR,
    referencia VARCHAR,
    cajero VARCHAR,
    estatus VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cvepago AS id_pago,
        COALESCE(p.referencia::VARCHAR, '') AS clave_cuenta,
        p.cvepago::VARCHAR AS folio_pago,
        CASE
            WHEN p.axoini > 0 AND p.bimini > 0 THEN
                p.axoini::VARCHAR || '-' ||
                CASE p.bimini
                    WHEN 1 THEN 'Ene-Feb'
                    WHEN 2 THEN 'Mar-Abr'
                    WHEN 3 THEN 'May-Jun'
                    WHEN 4 THEN 'Jul-Ago'
                    WHEN 5 THEN 'Sep-Oct'
                    WHEN 6 THEN 'Nov-Dic'
                    ELSE 'N/A'
                END
            WHEN p.axoini > 0 THEN p.axoini::VARCHAR
            ELSE 'N/A'
        END AS fecha_pago,
        COALESCE(p.contribuyente, 'N/A')::VARCHAR AS contribuyente,
        COALESCE(p.domicilio, '')::VARCHAR AS domicilio,
        COALESCE(p.concepto, '')::TEXT AS concepto,
        0::NUMERIC AS monto,
        'N/A'::VARCHAR AS forma_pago,
        COALESCE(p.referencia::VARCHAR, '')::VARCHAR AS referencia,
        'N/A'::VARCHAR AS cajero,
        'Pagado'::VARCHAR AS estatus,
        ''::TEXT AS observaciones
    FROM public.pago_diversos p
    WHERE
        CASE
            WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
            ELSE (
                p.cvepago::TEXT ILIKE '%' || p_clave_cuenta || '%'
                OR p.contribuyente ILIKE '%' || p_clave_cuenta || '%'
                OR p.concepto ILIKE '%' || p_clave_cuenta || '%'
                OR p.referencia::TEXT ILIKE '%' || p_clave_cuenta || '%'
            )
        END
    ORDER BY p.cvepago DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.pago_diversos -> Tabla de pagos diversos
--
-- Mapeo de campos:
-- id_pago → cvepago (identificador único del pago)
-- clave_cuenta → referencia (número de referencia)
-- folio_pago → cvepago (mismo que id_pago)
-- fecha_pago → derivado de axoini + bimini (año-bimestre)
-- contribuyente → contribuyente (nombre del contribuyente)
-- domicilio → domicilio (domicilio del contribuyente)
-- concepto → concepto (descripción del pago)
-- monto → N/A (no existe en tabla, retorna 0)
-- forma_pago → N/A (no existe en tabla)
-- referencia → referencia (número de referencia)
-- cajero → N/A (no existe en tabla)
-- estatus → 'Pagado' (todos los registros son pagos completados)
-- observaciones → '' (no existe en tabla)
--
-- BÚSQUEDA:
-- El filtro p_clave_cuenta busca en 4 campos:
-- 1. cvepago (ID del pago)
-- 2. contribuyente (nombre)
-- 3. concepto (descripción del pago)
-- 4. referencia (número de referencia)
--
-- IMPORTANTE:
-- - Búsqueda con ILIKE (case-insensitive)
-- - Límite de 100 registros por consulta
-- - Ordenamiento: cvepago descendente (más reciente primero)
-- - fecha_pago se construye como "año-bimestre" (ej: 2014-Nov-Dic)
-- - monto no está disponible en la tabla (retorna 0)
-- - forma_pago, cajero no disponibles (retorna 'N/A')
-- - estatus siempre es 'Pagado' (son registros históricos de pagos)
--
-- ESTADÍSTICAS:
-- Total pagos diversos: 440,073
-- Años registrados: principalmente 2014
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_pagosdivfrm('');  -- Últimos 100 pagos
-- SELECT * FROM publico.recaudadora_pagosdivfrm('HERNANDEZ');  -- Buscar por contribuyente
-- SELECT * FROM publico.recaudadora_pagosdivfrm('CERTIFICADO');  -- Buscar por concepto
-- SELECT * FROM publico.recaudadora_pagosdivfrm('282234');  -- Buscar por referencia
