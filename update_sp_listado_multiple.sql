-- Actualización del Stored Procedure para ListadoMultiple.vue
-- Usa las tablas existentes: publico.pagos, publico.c_conceptos

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_listado_multiple'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_listado_multiple(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para listado múltiple con paginación
CREATE OR REPLACE FUNCTION publico.recaudadora_listado_multiple(
    p_filtro VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    id INTEGER,
    folio VARCHAR,
    tipo_movimiento VARCHAR,
    clave_cuenta VARCHAR,
    contribuyente VARCHAR,
    concepto VARCHAR,
    descripcion VARCHAR,
    monto NUMERIC,
    fecha_movimiento DATE,
    estado VARCHAR,
    usuario VARCHAR,
    recaudadora VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cvepago AS id,
        COALESCE(p.folio::TEXT, '')::VARCHAR AS folio,
        'Pago'::VARCHAR AS tipo_movimiento,
        COALESCE(p.cvecuenta::TEXT, '')::VARCHAR AS clave_cuenta,
        ('Cuenta ' || COALESCE(p.cvecuenta::TEXT, ''))::VARCHAR AS contribuyente,
        TRIM(COALESCE(c.descripcion, 'Sin Concepto'))::VARCHAR AS concepto,
        TRIM(COALESCE(c.ncorto, ''))::VARCHAR AS descripcion,
        COALESCE(p.importe, 0)::NUMERIC AS monto,
        p.fecha AS fecha_movimiento,
        CASE
            WHEN p.cvecanc IS NULL THEN 'Activo'
            ELSE 'Cancelado'
        END::VARCHAR AS estado,
        TRIM(COALESCE(p.cajero, ''))::VARCHAR AS usuario,
        COALESCE(p.recaud::TEXT, '')::VARCHAR AS recaudadora
    FROM publico.pagos p
    LEFT JOIN publico.c_conceptos c ON p.cveconcepto = c.cveconcepto
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                p.folio::TEXT ILIKE '%' || p_filtro || '%'
                OR p.cvecuenta::TEXT ILIKE '%' || p_filtro || '%'
                OR c.descripcion ILIKE '%' || p_filtro || '%'
                OR c.ncorto ILIKE '%' || p_filtro || '%'
                OR p.cajero ILIKE '%' || p_filtro || '%'
                OR p.recaud::TEXT ILIKE '%' || p_filtro || '%'
                OR (p.cvecanc IS NULL AND 'activo' ILIKE '%' || p_filtro || '%')
                OR (p.cvecanc IS NOT NULL AND 'cancelado' ILIKE '%' || p_filtro || '%')
            )
        END
    ORDER BY p.fecha DESC, p.cvepago DESC
    LIMIT p_limit
    OFFSET p_offset;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.pagos -> Tabla principal de pagos (13.8M registros)
-- publico.c_conceptos -> Catálogo de conceptos de pago (46 conceptos)
--
-- id: cvepago (ID único del pago)
-- folio: folio (número de folio del pago)
-- tipo_movimiento: 'Pago' (todos los registros son pagos)
-- clave_cuenta: cvecuenta (cuenta catastral o identificador)
-- contribuyente: 'Cuenta ' + cvecuenta (no hay nombre directo disponible)
-- concepto: descripcion del concepto (ej: "PAGO DE IMPUESTO PREDIAL")
-- descripcion: ncorto del concepto (nombre corto, ej: "PREDIAL")
-- monto: importe (monto del pago)
-- fecha_movimiento: fecha (fecha del pago)
-- estado: 'Activo' si no está cancelado, 'Cancelado' si tiene cvecanc
-- usuario: cajero (usuario que registró el pago)
-- recaudadora: recaud (número de recaudadora 1-10)

-- PARÁMETROS:
-- p_filtro: Texto para búsqueda general (folio, cuenta, concepto, cajero, estado)
-- p_offset: Registro inicial (para paginación)
-- p_limit: Cantidad de registros a retornar (default 100)

-- JOINS:
-- 1. publico.pagos LEFT JOIN publico.c_conceptos ON cveconcepto

-- FILTROS:
-- - Búsqueda general en folio, cuenta, concepto, descripción, cajero, recaudadora, estado

-- ORDENAMIENTO:
-- - Por fecha descendente (más recientes primero)
-- - Por ID de pago descendente (como criterio secundario)

-- LÍMITE:
-- - Máximo p_limit registros (default 100) para optimizar rendimiento

-- ESTADOS:
-- Activo: Pago válido (cvecanc IS NULL)
-- Cancelado: Pago cancelado (cvecanc IS NOT NULL)

-- CONCEPTOS PRINCIPALES:
-- 1: PAGO DE IMPUESTO PREDIAL
-- 2: PAGO DE IMPUESTO TRANSM. PATRIM.
-- 3: CERTIFICADOS DE NO ADEUDO
-- 4: PAGO DE DIVERSOS
-- 5: PAGO PREDIAL EN BANCOS
-- 6: PAGO DE MULTAS MUNICIPALES
-- 7: PAGO DE MULTAS FEDERALES
-- 8: PAGO DE LICENCIAS MUNICIPALES
-- ... (46 conceptos en total)

-- ESTADÍSTICAS:
-- Total pagos: 13,841,577
-- Pagos activos: 13,660,850 (98.7%)
-- Pagos cancelados: 180,727 (1.3%)
-- Pagos recientes (2024-2025): 635,875
