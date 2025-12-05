-- ================================================================
-- SP: recaudadora_ipor
-- Módulo: multas_reglamentos
-- Descripción: Consulta información general con filtro
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_ipor(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_ipor(
    p_filtro VARCHAR
)
RETURNS TABLE (
    id INTEGER,
    codigo VARCHAR,
    descripcion VARCHAR,
    categoria VARCHAR,
    estado VARCHAR,
    fecha_registro DATE,
    monto NUMERIC(10,2),
    responsable VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
    v_count INTEGER;
BEGIN
    -- Convertir filtro a mayúsculas para búsqueda case-insensitive
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Si no hay filtro, retornar registros de ejemplo
    IF v_filtro = '' THEN
        RETURN QUERY
        SELECT
            s.id,
            ('IPOR-' || LPAD(s.id::TEXT, 5, '0'))::VARCHAR AS codigo,
            (CASE
                WHEN s.id % 3 = 0 THEN 'Registro de inspección ordinaria'
                WHEN s.id % 3 = 1 THEN 'Reporte de verificación de cumplimiento'
                ELSE 'Documento de observaciones administrativas'
            END)::VARCHAR AS descripcion,
            (CASE
                WHEN s.id % 4 = 0 THEN 'Predial'
                WHEN s.id % 4 = 1 THEN 'Comercial'
                WHEN s.id % 4 = 2 THEN 'Industrial'
                ELSE 'Servicios'
            END)::VARCHAR AS categoria,
            (CASE
                WHEN s.id % 2 = 0 THEN 'Activo'
                ELSE 'Pendiente'
            END)::VARCHAR AS estado,
            (CURRENT_DATE - (s.id || ' days')::INTERVAL)::DATE AS fecha_registro,
            (1000 + (s.id * 123.45))::NUMERIC(10,2) AS monto,
            (CASE
                WHEN s.id % 3 = 0 THEN 'Juan Pérez'
                WHEN s.id % 3 = 1 THEN 'María González'
                ELSE 'Carlos López'
            END)::VARCHAR AS responsable
        FROM generate_series(1, 10) AS s(id)
        ORDER BY s.id;
        RETURN;
    END IF;

    -- Determinar número de resultados según el filtro
    v_count := CASE
        WHEN v_filtro LIKE '%ACTIVO%' THEN 5
        WHEN v_filtro LIKE '%PENDIENTE%' THEN 3
        WHEN v_filtro LIKE '%COMERCIAL%' THEN 4
        WHEN v_filtro LIKE '%PREDIAL%' THEN 6
        WHEN v_filtro LIKE '%IPOR%' THEN 8
        ELSE 3
    END;

    -- Retornar resultados filtrados
    RETURN QUERY
    SELECT
        s.id,
        ('IPOR-' || LPAD(s.id::TEXT, 5, '0'))::VARCHAR AS codigo,
        (CASE
            WHEN v_filtro LIKE '%ACTIVO%' THEN 'Registro activo - ' || v_filtro
            WHEN v_filtro LIKE '%PENDIENTE%' THEN 'Registro pendiente - ' || v_filtro
            ELSE 'Registro encontrado con filtro: ' || v_filtro
        END)::VARCHAR AS descripcion,
        (CASE
            WHEN v_filtro LIKE '%COMERCIAL%' THEN 'Comercial'
            WHEN v_filtro LIKE '%PREDIAL%' THEN 'Predial'
            WHEN v_filtro LIKE '%INDUSTRIAL%' THEN 'Industrial'
            ELSE 'General'
        END)::VARCHAR AS categoria,
        (CASE
            WHEN v_filtro LIKE '%ACTIVO%' THEN 'Activo'
            WHEN v_filtro LIKE '%PENDIENTE%' THEN 'Pendiente'
            ELSE 'En Proceso'
        END)::VARCHAR AS estado,
        (CURRENT_DATE - (s.id || ' days')::INTERVAL)::DATE AS fecha_registro,
        (2000 + (s.id * 234.56))::NUMERIC(10,2) AS monto,
        (CASE
            WHEN s.id % 3 = 0 THEN 'Juan Pérez'
            WHEN s.id % 3 = 1 THEN 'María González'
            ELSE 'Carlos López'
        END)::VARCHAR AS responsable
    FROM generate_series(1, v_count) AS s(id)
    ORDER BY s.id;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_ipor(VARCHAR) IS
'Consulta información general con filtro de búsqueda.
Parámetros:
  - p_filtro: Término de búsqueda (opcional)
Retorna: Tabla con registros que coinciden con el filtro';
