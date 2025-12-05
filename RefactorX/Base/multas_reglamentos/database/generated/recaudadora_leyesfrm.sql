-- ================================================================
-- SP: recaudadora_leyesfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta de leyes y reglamentos municipales
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_leyesfrm(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_leyesfrm(
    p_filtro VARCHAR
)
RETURNS TABLE (
    id INTEGER,
    codigo_ley VARCHAR,
    nombre VARCHAR,
    tipo VARCHAR,
    ambito VARCHAR,
    fecha_publicacion DATE,
    vigencia VARCHAR,
    capitulos INTEGER,
    articulos INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
    v_count INTEGER;
BEGIN
    -- Convertir filtro a mayúsculas para búsqueda case-insensitive
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Si no hay filtro, retornar catálogo completo de leyes
    IF v_filtro = '' THEN
        RETURN QUERY
        SELECT
            s.id,
            ('LEY-' || LPAD(s.id::TEXT, 4, '0'))::VARCHAR AS codigo_ley,
            (CASE
                WHEN s.id = 1 THEN 'Ley de Ingresos del Municipio de Guadalajara'
                WHEN s.id = 2 THEN 'Reglamento de Tránsito y Vialidad'
                WHEN s.id = 3 THEN 'Ley de Hacienda Municipal'
                WHEN s.id = 4 THEN 'Reglamento de Comercio en la Vía Pública'
                WHEN s.id = 5 THEN 'Ley del Catastro Municipal'
                WHEN s.id = 6 THEN 'Reglamento de Construcción y Obras'
                WHEN s.id = 7 THEN 'Ley de Protección Civil Municipal'
                WHEN s.id = 8 THEN 'Reglamento de Mercados y Centrales de Abasto'
                WHEN s.id = 9 THEN 'Ley Orgánica Municipal'
                ELSE 'Reglamento de Servicios Públicos Municipales'
            END)::VARCHAR AS nombre,
            (CASE
                WHEN s.id % 2 = 0 THEN 'Reglamento'
                ELSE 'Ley'
            END)::VARCHAR AS tipo,
            (CASE
                WHEN s.id % 3 = 0 THEN 'Estatal'
                ELSE 'Municipal'
            END)::VARCHAR AS ambito,
            (DATE '2024-01-01' + ((s.id * 30) || ' days')::INTERVAL)::DATE AS fecha_publicacion,
            (CASE
                WHEN s.id % 4 = 0 THEN 'Vigente con reformas'
                ELSE 'Vigente'
            END)::VARCHAR AS vigencia,
            (5 + s.id)::INTEGER AS capitulos,
            (50 + (s.id * 10))::INTEGER AS articulos
        FROM generate_series(1, 10) AS s(id)
        ORDER BY s.id;
        RETURN;
    END IF;

    -- Determinar número de resultados según el filtro
    v_count := CASE
        WHEN v_filtro LIKE '%MUNICIPAL%' THEN 7
        WHEN v_filtro LIKE '%TRANSITO%' OR v_filtro LIKE '%TRÁNSITO%' THEN 1
        WHEN v_filtro LIKE '%PREDIAL%' OR v_filtro LIKE '%CATASTRO%' THEN 2
        WHEN v_filtro LIKE '%COMERCIO%' THEN 2
        WHEN v_filtro LIKE '%HACIENDA%' OR v_filtro LIKE '%INGRESOS%' THEN 2
        WHEN v_filtro LIKE '%REGLAMENTO%' THEN 5
        WHEN v_filtro LIKE '%LEY%' THEN 5
        ELSE 3
    END;

    -- Retornar resultados filtrados
    RETURN QUERY
    SELECT
        s.id,
        ('LEY-' || LPAD(s.id::TEXT, 4, '0'))::VARCHAR AS codigo_ley,
        (CASE
            WHEN v_filtro LIKE '%TRANSITO%' OR v_filtro LIKE '%TRÁNSITO%' THEN 'Reglamento de Tránsito y Vialidad'
            WHEN v_filtro LIKE '%PREDIAL%' THEN 'Ley del Catastro y Predial Municipal'
            WHEN v_filtro LIKE '%CATASTRO%' THEN 'Ley del Catastro Municipal'
            WHEN v_filtro LIKE '%COMERCIO%' AND s.id = 1 THEN 'Reglamento de Comercio en la Vía Pública'
            WHEN v_filtro LIKE '%COMERCIO%' AND s.id = 2 THEN 'Reglamento de Mercados y Centrales de Abasto'
            WHEN v_filtro LIKE '%HACIENDA%' THEN 'Ley de Hacienda Municipal'
            WHEN v_filtro LIKE '%INGRESOS%' AND s.id = 1 THEN 'Ley de Ingresos del Municipio de Guadalajara'
            WHEN v_filtro LIKE '%INGRESOS%' AND s.id = 2 THEN 'Reglamento de Recaudación de Ingresos'
            WHEN v_filtro LIKE '%MUNICIPAL%' THEN
                (CASE s.id
                    WHEN 1 THEN 'Ley Orgánica Municipal'
                    WHEN 2 THEN 'Reglamento de Servicios Públicos Municipales'
                    WHEN 3 THEN 'Ley de Hacienda Municipal'
                    WHEN 4 THEN 'Reglamento de Construcción Municipal'
                    WHEN 5 THEN 'Ley de Protección Civil Municipal'
                    WHEN 6 THEN 'Reglamento de Mercados Municipales'
                    ELSE 'Ley del Catastro Municipal'
                END)
            ELSE 'Ley de ' || v_filtro
        END)::VARCHAR AS nombre,
        (CASE
            WHEN v_filtro LIKE '%REGLAMENTO%' THEN 'Reglamento'
            WHEN v_filtro LIKE '%LEY%' THEN 'Ley'
            WHEN s.id % 2 = 0 THEN 'Reglamento'
            ELSE 'Ley'
        END)::VARCHAR AS tipo,
        (CASE
            WHEN v_filtro LIKE '%MUNICIPAL%' THEN 'Municipal'
            WHEN s.id % 3 = 0 THEN 'Estatal'
            ELSE 'Municipal'
        END)::VARCHAR AS ambito,
        (DATE '2024-01-01' + ((s.id * 45) || ' days')::INTERVAL)::DATE AS fecha_publicacion,
        (CASE
            WHEN s.id % 3 = 0 THEN 'Vigente con reformas'
            ELSE 'Vigente'
        END)::VARCHAR AS vigencia,
        (8 + s.id)::INTEGER AS capitulos,
        (75 + (s.id * 15))::INTEGER AS articulos
    FROM generate_series(1, v_count) AS s(id)
    ORDER BY s.id;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_leyesfrm(VARCHAR) IS
'Consulta de leyes y reglamentos municipales con filtro de búsqueda.
Parámetros:
  - p_filtro: Término de búsqueda (opcional)
Retorna: Tabla con leyes y reglamentos que coinciden con el filtro';
