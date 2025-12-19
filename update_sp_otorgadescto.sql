-- Actualización del Stored Procedure para Otorgadescto.vue
-- Usa la tabla existente: public.aut_desctosotorgados

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_otorga_descto'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_otorga_descto(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para Otorgadescto con paginación
CREATE OR REPLACE FUNCTION publico.recaudadora_otorga_descto(
    p_clave_cuenta VARCHAR DEFAULT '',
    p_ejercicio INTEGER DEFAULT 0,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    folio_descto INTEGER,
    tipo INTEGER,
    id_multa VARCHAR,
    ejercicio INTEGER,
    descripcion VARCHAR,
    fecha_inicio DATE,
    fecha_fin DATE,
    porcentaje_autorizado SMALLINT,
    monto_autorizado NUMERIC,
    motivo VARCHAR,
    fecha_captura DATE,
    usuario_captura VARCHAR,
    vigencia VARCHAR,
    quien_autorizo SMALLINT,
    tipo_descuento VARCHAR,
    adeudo NUMERIC,
    total_count BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros que cumplen el filtro
    SELECT COUNT(*)
    INTO v_total_count
    FROM public.aut_desctosotorgados d
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR d.id_multa::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR d.axo = p_ejercicio);

    -- Retornar registros con paginación
    RETURN QUERY
    SELECT
        d.folio_descto,
        d.tipo,
        TRIM(d.id_multa)::VARCHAR AS id_multa,
        COALESCE(d.axo, 0)::INTEGER AS ejercicio,
        COALESCE(d.datos_descto, '')::VARCHAR AS descripcion,
        d.fecha_inicio,
        d.fecha_fin,
        COALESCE(d.por_aut, 0)::SMALLINT AS porcentaje_autorizado,
        COALESCE(d.monto_aut, 0)::NUMERIC AS monto_autorizado,
        COALESCE(d.motivo, '')::VARCHAR AS motivo,
        d.fecha_act AS fecha_captura,
        TRIM(COALESCE(d.user_cap, ''))::VARCHAR AS usuario_captura,
        CASE
            WHEN TRIM(d.vigencia) = 'B' THEN 'Vigente'
            WHEN TRIM(d.vigencia) = 'C' THEN 'Cancelado'
            ELSE 'Desconocido'
        END::VARCHAR AS vigencia,
        COALESCE(d.quien_aut, 0)::SMALLINT AS quien_autorizo,
        CASE
            WHEN TRIM(d.tipo_descto) = 'P' THEN 'Porcentaje'
            WHEN TRIM(d.tipo_descto) = 'I' THEN 'Importe'
            ELSE 'Desconocido'
        END::VARCHAR AS tipo_descuento,
        COALESCE(d.adeudo, 0)::NUMERIC AS adeudo,
        v_total_count AS total_count
    FROM public.aut_desctosotorgados d
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR d.id_multa::TEXT ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR d.axo = p_ejercicio)
    ORDER BY d.fecha_act DESC, d.folio_descto DESC
    OFFSET p_offset
    LIMIT p_limit;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.aut_desctosotorgados -> Tabla de autorizaciones de descuentos otorgados
--
-- Mapeo de campos:
-- folio_descto → folio_descto (identificador único del descuento)
-- tipo → tipo (tipo de descuento, catálogo)
-- id_multa → id_multa (identificador de la multa/cuenta)
-- ejercicio → axo (año del descuento)
-- descripcion → datos_descto (descripción del descuento)
-- fecha_inicio → fecha_inicio (fecha inicio de vigencia)
-- fecha_fin → fecha_fin (fecha fin de vigencia)
-- porcentaje_autorizado → por_aut (porcentaje autorizado)
-- monto_autorizado → monto_aut (monto autorizado en pesos)
-- motivo → motivo (motivo del descuento)
-- fecha_captura → fecha_act (fecha de captura/actualización)
-- usuario_captura → user_cap (usuario que capturó)
-- vigencia → vigencia (B=Vigente, C=Cancelado)
-- quien_autorizo → quien_aut (quien autorizó el descuento)
-- tipo_descuento → tipo_descto (P=Porcentaje, I=Importe)
-- adeudo → adeudo (adeudo original)
-- total_count → total de registros que cumplen el filtro (para paginación)
--
-- BÚSQUEDA:
-- El filtro p_clave_cuenta busca en:
-- - id_multa (folio/identificador de multa)
--
-- El filtro p_ejercicio busca en:
-- - axo (año del descuento)
--
-- IMPORTANTE:
-- - Búsqueda con ILIKE (case-insensitive)
-- - Paginación con OFFSET y LIMIT
-- - total_count para mostrar paginación en frontend
-- - Vigencia: B=Vigente, C=Cancelado
-- - Tipo descuento: P=Porcentaje, I=Importe
-- - Ordenamiento: fecha más reciente primero
--
-- ESTADÍSTICAS:
-- Total descuentos otorgados: 33
-- Años: 2013-2023
-- Tipo P (Porcentaje): mayoría
-- Tipo I (Importe): minoría
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_otorga_descto('', 0, 0, 50);  -- Primera página (todos)
-- SELECT * FROM publico.recaudadora_otorga_descto('JBB3383', 0, 0, 50);  -- Buscar por id_multa
-- SELECT * FROM publico.recaudadora_otorga_descto('', 2022, 0, 50);  -- Buscar por año 2022
-- SELECT * FROM publico.recaudadora_otorga_descto('317396', 2013, 0, 50);  -- Buscar por ambos filtros
