-- Actualización del Stored Procedure para multas400frm.vue
-- Usa la tabla existente: publico.multas_mpal_400

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_multas400frm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_multas400frm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para multas400frm
CREATE OR REPLACE FUNCTION publico.recaudadora_multas400frm(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_multa VARCHAR,
    num_acta VARCHAR,
    axo_acta VARCHAR,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    id_dependencia VARCHAR,
    expediente VARCHAR,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    cvepago VARCHAR,
    fecha_recepcion DATE,
    observacion TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.numacta::VARCHAR AS id_multa,
        m.numacta::VARCHAR AS num_acta,
        m.axoacta::VARCHAR AS axo_acta,
        -- Convertir fecha de INTEGER a DATE (formato YYMMDD o YYYYMMDD)
        CASE
            WHEN m.fecalt > 0 THEN
                CASE
                    WHEN LENGTH(m.fecalt::TEXT) = 8 THEN
                        TO_DATE(m.fecalt::TEXT, 'YYYYMMDD')
                    WHEN LENGTH(m.fecalt::TEXT) = 6 THEN
                        TO_DATE('19' || m.fecalt::TEXT, 'YYYYMMDD')
                    WHEN LENGTH(m.fecalt::TEXT) < 6 THEN
                        TO_DATE('19' || LPAD(m.fecalt::TEXT, 6, '0'), 'YYYYMMDD')
                    ELSE NULL
                END
            ELSE NULL
        END AS fecha_acta,
        TRIM(m.nombre)::VARCHAR AS contribuyente,
        TRIM(m.domici)::VARCHAR AS domicilio,
        m.depen::VARCHAR AS id_dependencia,
        ''::VARCHAR AS expediente,  -- No disponible en esta tabla
        COALESCE(m.impmul, 0)::NUMERIC AS multa,
        COALESCE(m.impini, 0)::NUMERIC AS gastos,
        (COALESCE(m.impmul, 0) + COALESCE(m.impini, 0))::NUMERIC AS total,
        NULL::VARCHAR AS cvepago,  -- No disponible
        -- Convertir fecha de recepción (formato YYMMDD o YYYYMMDD)
        CASE
            WHEN m.fecrec > 0 THEN
                CASE
                    WHEN LENGTH(m.fecrec::TEXT) = 8 THEN
                        TO_DATE(m.fecrec::TEXT, 'YYYYMMDD')
                    WHEN LENGTH(m.fecrec::TEXT) = 6 THEN
                        TO_DATE('19' || m.fecrec::TEXT, 'YYYYMMDD')
                    WHEN LENGTH(m.fecrec::TEXT) < 6 THEN
                        TO_DATE('19' || LPAD(m.fecrec::TEXT, 6, '0'), 'YYYYMMDD')
                    ELSE NULL
                END
            ELSE NULL
        END AS fecha_recepcion,
        CASE m.cvevig
            WHEN 'A' THEN 'Activa'
            WHEN 'P' THEN 'Pagada'
            WHEN 'C' THEN 'Cancelada'
            WHEN 'B' THEN 'Estado B'
            WHEN 'T' THEN 'Estado T'
            ELSE 'Desconocido'
        END::TEXT AS observacion
    FROM publico.multas_mpal_400 m
    WHERE CASE
        WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
        ELSE (m.numacta::TEXT ILIKE '%' || p_filtro || '%'
              OR m.axoacta::TEXT ILIKE '%' || p_filtro || '%'
              OR TRIM(m.nombre) ILIKE '%' || p_filtro || '%'
              OR m.depen::TEXT ILIKE '%' || p_filtro || '%'
              OR m.numlote::TEXT ILIKE '%' || p_filtro || '%')
    END
    ORDER BY m.fecalt DESC, m.numacta DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.multas_mpal_400 -> Tabla de multas municipales formato 400
--
-- Mapeo de campos:
-- id_multa → numacta (número de acta como identificador)
-- num_acta → numacta (número de acta)
-- axo_acta → axoacta (año de acta)
-- fecha_acta → fecalt (fecha alta, convertida de INTEGER a DATE)
-- contribuyente → nombre (nombre del contribuyente, trimmed)
-- domicilio → domici (domicilio, trimmed)
-- id_dependencia → depen (código de dependencia)
-- expediente → '' (no disponible en esta tabla)
-- multa → impmul (importe de multa)
-- gastos → impini (importe inicial, usado como gastos)
-- total → impmul + impini (suma de multa y gastos)
-- cvepago → NULL (no disponible)
-- fecha_recepcion → fecrec (fecha recepción, convertida)
-- observacion → descripción del estado (cvevig)
--
-- Estados de vigencia (cvevig):
-- 'A' = Activa (104,296 registros)
-- 'P' = Pagada (159,624 registros)
-- 'C' = Cancelada (1,344 registros)
-- 'B' = Estado B (7,815 registros)
-- 'T' = Estado T (168 registros)
--
-- IMPORTANTE:
-- - Las fechas están almacenadas como INTEGER en formato YYYYMMDD
-- - La conversión se hace con TO_DATE(valor::TEXT, 'YYYYMMDD')
-- - Los campos de texto están en formato CHARACTER con espacios al final
-- - Se usa TRIM() para limpiar espacios
-- - Límite de 100 registros para optimizar rendimiento
--
-- ESTADÍSTICAS:
-- Total multas municipales: 273,247
-- Activas: 104,296 (38.2%)
-- Pagadas: 159,624 (58.4%)
-- Canceladas: 1,344 (0.5%)
-- Otras: 7,983 (2.9%)
