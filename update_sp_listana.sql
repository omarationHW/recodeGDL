-- Actualización del Stored Procedure para ListAna.vue (Listado Analítico)
-- Usa las tablas existentes: public.reqbfpredial, public.detreqbfpredial, public.cartainvpredial

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_listana'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_listana(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para listado analítico con paginación
CREATE OR REPLACE FUNCTION publico.recaudadora_listana(
    p_filtro VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    clave_cuenta VARCHAR,
    contribuyente VARCHAR,
    concepto VARCHAR,
    impuesto NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    actualizacion NUMERIC,
    total NUMERIC,
    estado VARCHAR,
    fecha_emision DATE,
    total_count BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Primero obtener el conteo total
    SELECT COUNT(*)
    INTO v_total_count
    FROM public.reqbfpredial r
    LEFT JOIN public.detreqbfpredial d ON r.cvecuenta = d.cvecuenta
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                r.cvecuenta::TEXT ILIKE '%' || p_filtro || '%'
                OR r.vigencia ILIKE '%' || p_filtro || '%'
            )
        END;

    -- Retornar los resultados paginados
    RETURN QUERY
    SELECT
        COALESCE(r.cvecuenta::TEXT, '')::VARCHAR AS clave_cuenta,
        TRIM(COALESCE(c.nombre, 'Cuenta ' || r.cvecuenta::TEXT))::VARCHAR AS contribuyente,
        ('Año ' || COALESCE(d.axo::TEXT, '') ||
         ' Bim ' || COALESCE(d.bimini::TEXT, '') ||
         '-' || COALESCE(d.bimfin::TEXT, ''))::VARCHAR AS concepto,
        COALESCE(d.impuesto, r.impuesto, 0)::NUMERIC AS impuesto,
        COALESCE(d.recargos, r.recargos, 0)::NUMERIC AS recargos,
        COALESCE(r.multas, 0)::NUMERIC AS multas,
        0::NUMERIC AS actualizacion,
        COALESCE(
            d.impuesto + d.recargos,
            r.total,
            0
        )::NUMERIC AS total,
        CASE r.vigencia
            WHEN 'V' THEN 'Vigente'
            WHEN 'C' THEN 'Cancelado'
            WHEN 'P' THEN 'Pagado'
            WHEN 'X' THEN 'Expirado'
            WHEN 'i' THEN 'Incompleto'
            ELSE COALESCE(r.vigencia, 'Sin Estado')
        END::VARCHAR AS estado,
        r.fecemi AS fecha_emision,
        v_total_count AS total_count
    FROM public.reqbfpredial r
    LEFT JOIN public.detreqbfpredial d ON r.cvecuenta = d.cvecuenta
    LEFT JOIN public.cartainvpredial c ON r.cvecuenta = c.cvecuenta
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                r.cvecuenta::TEXT ILIKE '%' || p_filtro || '%'
                OR r.vigencia ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY r.cvecuenta, d.axo
    LIMIT p_limit
    OFFSET p_offset;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.reqbfpredial -> Tabla principal de requerimientos prediales
-- public.detreqbfpredial -> Detalle por año y bimestre
-- public.cartainvpredial -> Información del propietario (nombre)
--
-- clave_cuenta: cvecuenta (número de cuenta catastral)
-- contribuyente: nombre del propietario o "Cuenta {número}" si no hay nombre
-- concepto: "Año {axo} Bim {bimini}-{bimfin}" (describe el periodo)
-- impuesto: impuesto del detalle o del requerimiento
-- recargos: recargos del detalle o del requerimiento
-- multas: multas del requerimiento
-- actualizacion: 0 (detreqbfpredial no tiene este campo)
-- total: suma de impuesto + recargos del detalle, o total del requerimiento
-- estado: mapeo de vigencia a texto descriptivo
-- fecha_emision: fecha de emisión del requerimiento
-- total_count: conteo total para paginación

-- PARÁMETROS:
-- p_filtro: Texto para búsqueda en clave_cuenta o estado
-- p_offset: Registro inicial (para paginación)
-- p_limit: Cantidad de registros a retornar (default 50)

-- JOINS:
-- 1. public.reqbfpredial LEFT JOIN public.detreqbfpredial ON cvecuenta
-- 2. public.reqbfpredial LEFT JOIN public.cartainvpredial ON cvecuenta

-- ORDENAMIENTO:
-- - Por clave_cuenta (cvecuenta) ascendente
-- - Por año (axo) ascendente

-- PAGINACIÓN:
-- - Incluye campo total_count con el total de registros
-- - Usa LIMIT y OFFSET para paginación

-- ESTADOS:
-- V: Vigente
-- C: Cancelado
-- P: Pagado
-- X: Expirado
-- i: Incompleto
