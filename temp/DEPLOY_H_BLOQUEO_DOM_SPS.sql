-- ============================================
-- STORED PROCEDURES PARA H_BLOQUEO_DOM
-- Componente: h_bloqueoDomiciliosfrm.vue
-- Fecha: 2025-11-06
-- Descripción: Historial de bloqueos de domicilios
-- ============================================

-- ============================================
-- SP 1/4: h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom
-- Descripción: Listar/filtrar bloqueos históricos con paginación
-- ============================================
CREATE OR REPLACE FUNCTION public.h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_calle VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_tipo_bloqueo VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id INTEGER,
    calle VARCHAR,
    numero VARCHAR,
    colonia VARCHAR,
    tipo_bloqueo VARCHAR,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    usuario VARCHAR,
    motivo VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    -- Calcular offset
    v_offset := (p_page - 1) * p_limit;

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total
    FROM public.h_bloqueo_dom h
    WHERE (p_fecha_inicio IS NULL OR h.fecha_mov >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR h.fecha_mov <= p_fecha_fin)
      AND (p_calle IS NULL OR UPPER(TRIM(h.calle)) LIKE '%' || UPPER(p_calle) || '%')
      AND (p_colonia IS NULL) -- No hay campo colonia en la tabla
      AND (p_tipo_bloqueo IS NULL OR UPPER(TRIM(h.tipo_mov)) = UPPER(p_tipo_bloqueo));

    -- Retornar datos paginados
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY h.fecha_mov DESC)::INTEGER as id,
        TRIM(COALESCE(h.calle, ''))::VARCHAR as calle,
        CASE
            WHEN h.num_ext IS NOT NULL AND TRIM(h.let_ext) != '' THEN
                h.num_ext::VARCHAR || ' ' || TRIM(h.let_ext)
            WHEN h.num_ext IS NOT NULL THEN
                h.num_ext::VARCHAR
            ELSE 'S/N'
        END::VARCHAR as numero,
        'N/A'::VARCHAR as colonia, -- Campo no existe en tabla
        TRIM(COALESCE(h.tipo_mov, 'N/A'))::VARCHAR as tipo_bloqueo,
        h.fecha_mov as fecha_inicio,
        h.fecha_mov as fecha_fin, -- Usando fecha_mov como ambas fechas
        TRIM(COALESCE(h.modifico, h.capturista, 'N/A'))::VARCHAR as usuario,
        TRIM(COALESCE(h.motivo_mov, h.observacion, ''))::VARCHAR as motivo,
        v_total
    FROM public.h_bloqueo_dom h
    WHERE (p_fecha_inicio IS NULL OR h.fecha_mov >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR h.fecha_mov <= p_fecha_fin)
      AND (p_calle IS NULL OR UPPER(TRIM(h.calle)) LIKE '%' || UPPER(p_calle) || '%')
      AND (p_colonia IS NULL)
      AND (p_tipo_bloqueo IS NULL OR UPPER(TRIM(h.tipo_mov)) = UPPER(p_tipo_bloqueo))
    ORDER BY h.fecha_mov DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle
-- Descripción: Obtener detalle completo de un bloqueo
-- ============================================
CREATE OR REPLACE FUNCTION public.h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle(
    p_id INTEGER
)
RETURNS TABLE (
    id INTEGER,
    calle VARCHAR,
    numero VARCHAR,
    colonia VARCHAR,
    tipo_bloqueo VARCHAR,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    usuario VARCHAR,
    motivo VARCHAR,
    observacion VARCHAR,
    cvecalle INTEGER,
    cvecuenta INTEGER,
    folio INTEGER,
    capturista VARCHAR,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p_id as id,
        TRIM(COALESCE(h.calle, ''))::VARCHAR as calle,
        CASE
            WHEN h.num_ext IS NOT NULL AND TRIM(h.let_ext) != '' THEN
                h.num_ext::VARCHAR || ' ' || TRIM(h.let_ext)
            WHEN h.num_ext IS NOT NULL THEN
                h.num_ext::VARCHAR
            ELSE 'S/N'
        END::VARCHAR as numero,
        'N/A'::VARCHAR as colonia,
        TRIM(COALESCE(h.tipo_mov, 'N/A'))::VARCHAR as tipo_bloqueo,
        h.fecha_mov as fecha_inicio,
        h.fecha_mov as fecha_fin,
        TRIM(COALESCE(h.modifico, h.capturista, 'N/A'))::VARCHAR as usuario,
        TRIM(COALESCE(h.motivo_mov, ''))::VARCHAR as motivo,
        TRIM(COALESCE(h.observacion, ''))::VARCHAR as observacion,
        h.cvecalle,
        h.cvecuenta,
        h.folio,
        TRIM(COALESCE(h.capturista, ''))::VARCHAR as capturista,
        TRIM(COALESCE(h.vig, ''))::VARCHAR as vigencia
    FROM public.h_bloqueo_dom h
    LIMIT 1 OFFSET (p_id - 1);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel
-- Descripción: Preparar datos para exportar a Excel
-- ============================================
CREATE OR REPLACE FUNCTION public.h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_calle VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_tipo_bloqueo VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    calle VARCHAR,
    numero VARCHAR,
    tipo_bloqueo VARCHAR,
    fecha_movimiento VARCHAR,
    usuario VARCHAR,
    motivo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(COALESCE(h.calle, ''))::VARCHAR as calle,
        CASE
            WHEN h.num_ext IS NOT NULL AND TRIM(h.let_ext) != '' THEN
                h.num_ext::VARCHAR || ' ' || TRIM(h.let_ext)
            WHEN h.num_ext IS NOT NULL THEN
                h.num_ext::VARCHAR
            ELSE 'S/N'
        END::VARCHAR as numero,
        TRIM(COALESCE(h.tipo_mov, 'N/A'))::VARCHAR as tipo_bloqueo,
        TO_CHAR(h.fecha_mov, 'DD/MM/YYYY HH24:MI')::VARCHAR as fecha_movimiento,
        TRIM(COALESCE(h.modifico, h.capturista, 'N/A'))::VARCHAR as usuario,
        TRIM(COALESCE(h.motivo_mov, h.observacion, ''))::VARCHAR as motivo
    FROM public.h_bloqueo_dom h
    WHERE (p_fecha_inicio IS NULL OR h.fecha_mov >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR h.fecha_mov <= p_fecha_fin)
      AND (p_calle IS NULL OR UPPER(TRIM(h.calle)) LIKE '%' || UPPER(p_calle) || '%')
      AND (p_colonia IS NULL)
      AND (p_tipo_bloqueo IS NULL OR UPPER(TRIM(h.tipo_mov)) = UPPER(p_tipo_bloqueo))
    ORDER BY h.fecha_mov DESC
    LIMIT 10000; -- Límite de seguridad para Excel
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report
-- Descripción: Preparar datos para imprimir reporte
-- ============================================
CREATE OR REPLACE FUNCTION public.h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_calle VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_tipo_bloqueo VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    calle VARCHAR,
    numero VARCHAR,
    tipo_bloqueo VARCHAR,
    fecha_movimiento VARCHAR,
    usuario VARCHAR,
    motivo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(COALESCE(h.calle, ''))::VARCHAR as calle,
        CASE
            WHEN h.num_ext IS NOT NULL AND TRIM(h.let_ext) != '' THEN
                h.num_ext::VARCHAR || ' ' || TRIM(h.let_ext)
            WHEN h.num_ext IS NOT NULL THEN
                h.num_ext::VARCHAR
            ELSE 'S/N'
        END::VARCHAR as numero,
        TRIM(COALESCE(h.tipo_mov, 'N/A'))::VARCHAR as tipo_bloqueo,
        TO_CHAR(h.fecha_mov, 'DD/MM/YYYY HH24:MI')::VARCHAR as fecha_movimiento,
        TRIM(COALESCE(h.modifico, h.capturista, 'N/A'))::VARCHAR as usuario,
        TRIM(COALESCE(h.motivo_mov, h.observacion, ''))::VARCHAR as motivo
    FROM public.h_bloqueo_dom h
    WHERE (p_fecha_inicio IS NULL OR h.fecha_mov >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR h.fecha_mov <= p_fecha_fin)
      AND (p_calle IS NULL OR UPPER(TRIM(h.calle)) LIKE '%' || UPPER(p_calle) || '%')
      AND (p_colonia IS NULL)
      AND (p_tipo_bloqueo IS NULL OR UPPER(TRIM(h.tipo_mov)) = UPPER(p_tipo_bloqueo))
    ORDER BY h.fecha_mov DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
